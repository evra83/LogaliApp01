CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS:
      BEGIN OF travel_status,
        open     TYPE c LENGTH 1 VALUE 'O',
        accepted TYPE c LENGTH 1 VALUE 'A',
        rejected TYPE c LENGTH 1 VALUE 'X',
      END OF travel_status,

      BEGIN OF travel_criticality,
        neutral     TYPE i VALUE 0, "Transparente
        negative    TYPE i VALUE 1, "Rojo
        positive    TYPE i VALUE 3, "Verde
        information TYPE i VALUE 5, "Azul
      END OF travel_criticality.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS setTravelnumber FOR DETERMINE ON SAVE
       keys FOR Travel~setTravelnumber.
    METHODS setInitialDefault FOR DETERMINE ON MODIFY
       keys FOR Travel~setInitialDefault.
    METHODS validateAgency FOR VALIDATE ON SAVE
       keys FOR Travel~validateAgency.
    METHODS validateCostumer FOR VALIDATE ON SAVE
       keys FOR Travel~validateCostumer.
    METHODS validateDates FOR VALIDATE ON SAVE
       keys FOR Travel~validateDates.
    METHODS validateBookingFee FOR VALIDATE ON SAVE
      keys FOR Travel~validateBookingFee.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD setTravelnumber.

    READ ENTITIES OF zi_travel_ev IN LOCAL MODE "Se saca de la interfaz
        ENTITY travel                           "Se saca de la interfaz
        FIELDS ( TravelId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    DELETE travels WHERE TravelId IS NOT INITIAL.

    CHECK travels IS NOT INITIAL.

    SELECT SINGLE FROM ztravel_ev FIELDS MAX( travel_id ) INTO @DATA(lv_maxtravelid).

    MODIFY ENTITIES OF zi_travel_ev IN LOCAL MODE
		ENTITY travel
		UPDATE FIELDS ( TravelId )
		WITH VALUE #( FOR travel IN travels INDEX INTO i (
		  %tky        = travel-%tky
		  TravelId    = lv_maxtravelid + 1
		) ).

  ENDMETHOD.

  METHOD setInitialDefault.

    READ ENTITIES OF zi_travel_ev IN LOCAL MODE "Se saca de la interfaz
        ENTITY travel                           "Se saca de la interfaz
        FIELDS ( OverallStatus OverallStatusCriticality CurrencyCode )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    DELETE travels WHERE OverallStatus IS NOT INITIAL.

    CHECK travels IS NOT INITIAL.

    MODIFY ENTITIES OF zi_travel_ev IN LOCAL MODE
        ENTITY travel
        UPDATE FIELDS ( OverallStatus OverallStatusCriticality CurrencyCode )
        WITH VALUE #( FOR travel IN travels (
          %tky        = travel-%tky
          OverallStatus = COND #(
                              WHEN travel-OverallStatus IS INITIAL THEN travel_status-open
    						  ELSE travel-OverallStatus )
    	  OverallStatusCriticality =   COND #(
        							     WHEN travel-OverallStatusCriticality = 5 THEN travel_criticality-information
        							     ELSE travel-OverallStatusCriticality )
    	  CurrencyCode = COND #(
    	                       WHEN travel-CurrencyCode IS INITIAL THEN 'USD'        							          						
							   ELSE travel-CurrencyCode )
							          							          						
        ) ).

  ENDMETHOD.

  METHOD validateAgency.

*    Leer el campo que se  necesita en este caso AgencyId para saber si retorna valores
    READ ENTITIES OF zi_travel_ev IN LOCAL MODE
        ENTITY travel
        FIELDS ( AgencyId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

*    Declara un tipo de tabla interna para almacenar los valores de AgencyId y eliminar duplicados
    DATA: lt_Agencies TYPE SORTED TABLE OF /dmo/agency WITH UNIQUE KEY agency_id.
    lt_Agencies = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING agency_id = AgencyId EXCEPT * ).

*    No tiene en cuenta los registros que no tienen valor en el campo AgencyId
    DELETE lt_Agencies WHERE agency_id IS INITIAL.

*    Si hay registros con valor en el campo AgencyId, se realiza la validación de existencia en la tabla /dmo/agency
    IF lt_Agencies IS NOT INITIAL.

*      Retorna todas las agencias validas para el sistema
      SELECT FROM /dmo/agency FIELDS agency_id
		  FOR ALL ENTRIES IN @lt_Agencies
		  WHERE agency_id = @lt_Agencies-agency_id
		  INTO TABLE @DATA(lt_Agencies_valid).
      		
    ENDIF.

*    Recorre todos los agency ID y valida si existen en la tabla /dmo/agency, si no existen se agrega a la
*    tabla failed-travel y reported-travel con el mensaje de error correspondiente
    LOOP AT travels INTO DATA(travel).

      APPEND VALUE #(
          %tky = travel-%tky                "Se agrega el registro a la tabla reported-travel
          %state_Area = 'VALIDATE_AGENCY'   "Se agrega el registro a la tabla reported-travel
      ) TO reported-travel.

      IF travel-AgencyId IS INITIAL.        "Si el campo esta vacio se agrega a la tabla failed-travel y reported-travel con el mensaje de error correspondiente
        		
        APPEND VALUE #(
        	%tky = travel-%tky
		) TO failed-travel.
        			
        	APPEND VALUE #(
        	   %tky = travel-%tky
        	   %state_Area = 'VALIDATE_AGENCY'
        	   %msg = NEW /dmo/cm_flight_messages(     "Se agrega el mensaje de error a la tabla reported-travel
                    textid = /dmo/cm_flight_messages=>enter_agency_id
                    severity = if_abap_behv_message=>severity-error

        	   )
        	   %element-AgencyID  = if_Abap_behv=>mk-on    "Se agrega para ubicar el foco en el campo del error
        	) TO reported-travel.
        	
      ELSEIF NOT  line_exists( lt_Agencies_valid[ agency_id = travel-AgencyId ] ).

        APPEND VALUE #(
            %tky = travel-%tky
        ) TO failed-travel.

        APPEND VALUE #(
           %tky = travel-%tky
           %state_Area = 'VALIDATE_AGENCY'
           %msg = NEW /dmo/cm_flight_messages(     "Se agrega el mensaje de error a la tabla reported-travel
                agency_id = travel-AgencyId
                textid = /dmo/cm_flight_messages=>agency_unkown
                severity = if_abap_behv_message=>severity-error
           )
           %element-AgencyID  = if_Abap_behv=>mk-on    "Se agrega para ubicar el foco en el campo del error
        ) TO reported-travel.  	
        				
      ENDIF.

    ENDLOOP.



  ENDMETHOD.

  METHOD validateCostumer.

*    Leer el campo que se  necesita en este caso CustomerID para saber si retorna valores
    READ ENTITIES OF zi_travel_ev IN LOCAL MODE
        ENTITY travel
        FIELDS ( CustomerId )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

*    Declara un tipo de tabla interna para almacenar los valores de AgencyId y eliminar duplicados
    DATA: lt_customers TYPE SORTED TABLE OF /DMO/I_Customer  WITH UNIQUE KEY CustomerID.
    lt_customers = CORRESPONDING #( travels DISCARDING DUPLICATES MAPPING CustomerID = CustomerId EXCEPT * ).

*    No tiene en cuenta los registros que no tienen valor en el campo AgencyId
    DELETE lt_customers WHERE CustomerID IS INITIAL.

*    Si hay registros con valor en el campo AgencyId, se realiza la validación de existencia en la tabla /dmo/agency
    IF lt_customers IS NOT INITIAL.

*      Retorna todas las agencias validas para el sistema
      SELECT FROM /DMO/I_Customer FIELDS CustomerID
          FOR ALL ENTRIES IN @lt_customers
          WHERE CustomerID = @lt_customers-CustomerID
          INTO TABLE @DATA(lt_customers_valid).

    ENDIF.

*    Recorre todos los agency ID y valida si existen en la tabla /dmo/agency, si no existen se agrega a la
*    tabla failed-travel y reported-travel con el mensaje de error correspondiente
    LOOP AT travels INTO DATA(travel).

      APPEND VALUE #(
          %tky = travel-%tky                "Se agrega el registro a la tabla reported-travel
          %state_Area = 'VALIDATE_CUSTOMER'   "Se agrega el registro a la tabla reported-travel
      ) TO reported-travel.

      IF travel-CustomerId IS INITIAL.        "Si el campo esta vacio se agrega a la tabla failed-travel y reported-travel con el mensaje de error correspondiente

        APPEND VALUE #(
            %tky = travel-%tky
        ) TO failed-travel.

        APPEND VALUE #(
           %tky = travel-%tky
           %state_Area = 'VALIDATE_CUSTOMER'
           %msg = NEW /dmo/cm_flight_messages(     "Se agrega el mensaje de error a la tabla reported-travel
                textid = /dmo/cm_flight_messages=>enter_customer_id
                severity = if_abap_behv_message=>severity-error

           )
           %element-customerid  = if_Abap_behv=>mk-on    "Se agrega para ubicar el foco en el campo del error
        ) TO reported-travel.

      ELSEIF NOT  line_exists( lt_customers_valid[ CustomerID = travel-CustomerId ] ).

        APPEND VALUE #(
            %tky = travel-%tky
        ) TO failed-travel.

        APPEND VALUE #(
           %tky = travel-%tky
           %state_Area = 'VALIDATE_CUSTOMER'
           %msg = NEW /dmo/cm_flight_messages(     "Se agrega el mensaje de error a la tabla reported-travel
                customer_id = travel-CustomerId
                textid = /dmo/cm_flight_messages=>customer_unkown
                severity = if_abap_behv_message=>severity-error
           )
           %element-customerid  = if_Abap_behv=>mk-on    "Se agrega para ubicar el foco en el campo del error
        ) TO reported-travel.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDates.

*    Leer el campo que se  necesita en este caso CustomerID para saber si retorna valores
    READ ENTITIES OF zi_travel_ev IN LOCAL MODE
        ENTITY travel
        FIELDS ( BeginDate EndDate )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel).

      IF travel-BeginDate IS INITIAL OR travel-EndDate IS INITIAL.

        APPEND VALUE #(
            %tky = travel-%tky
            %state_Area = 'VALIDATE_DATES_RANGE'
        ) TO reported-travel.

        APPEND VALUE #(
            %tky = travel-%tky
        ) TO failed-travel.

        IF travel-BeginDate IS INITIAL.

          APPEND VALUE #(
             %tky = travel-%tky
             %state_Area = 'VALIDATE_DATES_RANGE'
             %msg = NEW /dmo/cm_flight_messages(     "Se agrega el mensaje de error a la tabla reported-travel
                  begin_date = travel-BeginDate
                  textid = /dmo/cm_flight_messages=>enter_begin_date
                  severity = if_abap_behv_message=>severity-error
             )
             %element-BeginDate  = if_Abap_behv=>mk-on
          ) TO reported-travel.

        ELSE.

          APPEND VALUE #(
         %tky = travel-%tky
         %state_Area = 'VALIDATE_DATES_RANGE'
         %msg = NEW /dmo/cm_flight_messages(     "Se agrega el mensaje de error a la tabla reported-travel
              end_date = travel-EndDate
              textid = /dmo/cm_flight_messages=>enter_end_date
              severity = if_abap_behv_message=>severity-error
         )
         %element-EndDate  = if_Abap_behv=>mk-on
      ) TO reported-travel.

        ENDIF.

      ELSEIF travel-BeginDate < cl_abap_context_info=>get_system_date( ).

        APPEND VALUE #(
            %tky = travel-%tky
            %state_Area = 'VALIDATE_DATES_RANGE'
        ) TO reported-travel.

        APPEND VALUE #(
            %tky = travel-%tky
        ) TO failed-travel.


        APPEND VALUE #(
           %tky = travel-%tky
           %state_Area = 'VALIDATE_DATES_RANGE'
           %msg = NEW /dmo/cm_flight_messages(     "Se agrega el mensaje de error a la tabla reported-travel
                begin_date = travel-BeginDate
                textid = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                severity = if_abap_behv_message=>severity-error
           )
           %element-BeginDate  = if_Abap_behv=>mk-on
        ) TO reported-travel.


      ELSEIF travel-BeginDate > travel-EndDate.

        APPEND VALUE #(
            %tky = travel-%tky
            %state_Area = 'VALIDATE_DATES_RANGE'
        ) TO reported-travel.

        APPEND VALUE #(
            %tky = travel-%tky
        ) TO failed-travel.


        APPEND VALUE #(
           %tky = travel-%tky
           %state_Area = 'VALIDATE_DATES_RANGE'
           %msg = NEW /dmo/cm_flight_messages(     "Se agrega el mensaje de error a la tabla reported-travel
                begin_date = travel-BeginDate
                end_date   = travel-EndDate
                textid = /dmo/cm_flight_messages=>begin_date_bef_end_date
                severity = if_abap_behv_message=>severity-error
           )
           %element-BeginDate  = if_Abap_behv=>mk-on
        ) TO reported-travel.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateBookingFee.

*    Leer el campo que se  necesita en este caso CustomerID para saber si retorna valores
    READ ENTITIES OF zi_travel_ev IN LOCAL MODE
        ENTITY travel
        FIELDS ( BookingFee )
        WITH CORRESPONDING #( keys )
        RESULT DATA(travels).

    LOOP AT travels INTO DATA(travel) where BookingFee <= 0.

        APPEND VALUE #(
            %tky = travel-%tky
            %state_Area = 'VALIDATE_BOOKING FEE'
        ) TO reported-travel.

        APPEND VALUE #(
            %tky = travel-%tky
        ) TO failed-travel.

        APPEND VALUE #(
           %tky = travel-%tky
           %state_Area = 'VALIDATE_BOOKING FEE'
           %msg = NEW /dmo/cm_flight_messages(     "Se agrega el mensaje de error a la tabla reported-travel
                textid = /dmo/cm_flight_messages=>booking_fee_invalid
                severity = if_abap_behv_message=>severity-error
           )
           %element-BookingFee  = if_Abap_behv=>mk-on
        ) TO reported-travel.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
