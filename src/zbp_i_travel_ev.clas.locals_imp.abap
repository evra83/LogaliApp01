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

ENDCLASS.
