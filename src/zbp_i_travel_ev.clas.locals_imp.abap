CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS setTravelnumber FOR DETERMINE ON SAVE
       keys FOR Travel~setTravelnumber.

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

ENDCLASS.
