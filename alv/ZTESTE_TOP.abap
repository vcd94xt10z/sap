CLASS gcl_alv1 DEFINITION DEFERRED.

DATA gt_alv1 TYPE STANDARD TABLE OF sairport. " modificar (ponto 1)
DATA gs_alv1 LIKE LINE OF gt_alv1.
DATA go_alv1 TYPE REF TO gcl_alv1.