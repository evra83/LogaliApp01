CLASS zcl_data_gen_ev DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .


  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_data_gen_ev IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    out->write( 'Deleting existing data...' ).

    DELETE FROM ztravel_ev.

    INSERT ztravel_ev FROM (
      SELECT FROM /dmo/travel
        FIELDS
          " client
          uuid( ) AS travel_uuid,
          travel_id,
          agency_id,
          customer_id,
          begin_date,
          end_date,
          currency_code,
          booking_fee,
          total_price,
          description,
          CASE status WHEN 'B' THEN 'A'
                      WHEN 'P' THEN 'O'
                      WHEN 'N' THEN 'O'
                      ELSE 'X' END AS overall_status,
          createdby AS local_created_by,
          createdat AS local_created_at,
          lastchangedby AS local_last_changed_by,
          lastchangedat AS local_last_changed_at,
          lastchangedat AS last_changed_at

    ).

    out->write( 'Adding Booking data' ).

    DELETE FROM zbooking_ev.

    INSERT zbooking_ev FROM (

      SELECT
        FROM /dmo/booking
        JOIN ztravel_ev ON /dmo/booking~travel_id = ztravel_ev~travel_id
        JOIN /dmo/travel ON /dmo/travel~travel_id = /dmo/booking~travel_id
        FIELDS
          "client,
          uuid( ) AS booking_uuid,
          ztravel_ev~travel_uuid AS parent_uuid,
          /dmo/booking~booking_id,
          /dmo/booking~booking_date,
          /dmo/booking~customer_id,
          /dmo/booking~carrier_id,
          /dmo/booking~connection_id,
          /dmo/booking~flight_date,
          /dmo/booking~currency_code,
          /dmo/booking~flight_price,
          CASE /dmo/travel~status WHEN 'P' THEN 'N'
                                  ELSE /dmo/travel~status END AS booking_status,
          ztravel_ev~last_changed_at AS local_last_changed_at ).

    out->write( 'Adding Booking Supplements data' ).

    DELETE FROM zbsuppl_ev.

    INSERT zbsuppl_ev FROM (
      SELECT FROM /dmo/book_suppl AS supp
        JOIN ztravel_ev  AS trvl ON trvl~travel_id = supp~travel_id
        JOIN zbooking_ev AS book ON book~parent_uuid = trvl~travel_uuid
                                  AND book~booking_id  = supp~booking_id
        FIELDS
          uuid( )              AS booksuppl_uuid,
          trvl~travel_uuid     AS root_uuid,
          book~booking_uuid    AS parent_uuid,
          supp~booking_supplement_id,
          supp~supplement_id,
          supp~currency_code,
          supp~price,
          trvl~last_changed_at AS local_last_changed_at ).

    out->write( 'Data generation complete.' ).

  ENDMETHOD.
ENDCLASS.
