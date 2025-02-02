(** Adding text *)

type color =
  Grey of float
| RGB of float * float * float
| CYMK of float * float * float * float

val colour_op : color -> Pdfops.t

val colour_op_stroke : color -> Pdfops.t

(** Justification of multiline text *)
type justification =
  | LeftJustify
  | CentreJustify
  | RightJustify

(** Call [add_texts linewidth outline fast fontname font bates batespad colour
position linespacing fontsize underneath text pages orientation
relative_to_cropbox midline_adjust topline filename pdf]. For details see cpdfmanual.pdf *)
val addtexts :
    ?embedinfo:(Pdf.t * Pdfio.bytes * string * Pdftext.encoding) ->
    float -> (*linewidth*)
    bool -> (*outline*)
    bool -> (*fast*)
    string -> (*fontname*)
    Pdftext.font option -> (*font*)
    int -> (* bates number *)
    int option -> (* bates padding width *)
    color -> (*colour*)
    Cpdfposition.position -> (*position*)
    float -> (*linespacing*)
    float -> (*fontsize*)
    bool -> (*underneath*)
    string ->(*text*)
    int list ->(*page range*)
    bool ->(*relative to cropbox?*)
    float ->(*opacity*)
    justification ->(*justification*)
    bool ->(*midline adjust?*)
    bool ->(*topline adjust?*)
    string ->(*filename*)
    float option -> (*extract_text_font_size*)
    string -> (* shift *)
    ?raw:bool -> (* raw *)
    Pdf.t ->(*pdf*)
    Pdf.t

(* Add a rectangle to the page *) 
val addrectangle :
    bool ->
    float * float ->
    color ->
    bool ->
    float ->
    float ->
    Cpdfposition.position ->
    bool -> bool -> int list -> Pdf.t -> Pdf.t
