INTERFACE zif_sa_ap_callback
  PUBLIC.

  TYPES:
    BEGIN OF ty_result,
      success       TYPE abap_bool,
      document_no   TYPE c LENGTH 20,
      document_year TYPE n LENGTH 4,
      message       TYPE c LENGTH 255,
    END OF ty_result.

  METHODS execute
    IMPORTING
      request_uuid TYPE sysuuid_x16
      source_uuid  TYPE sysuuid_x16
    RETURNING
      VALUE(result) TYPE ty_result.
ENDINTERFACE.
