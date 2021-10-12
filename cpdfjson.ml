open Pdfutil
open Cpdferror

module J = Cpdfyojson.Safe
module P = Pdf
module O = Pdfops

let opf = function
  | `Assoc ["F", `Float f] -> f
  | `Assoc ["F", `Int i] -> float_of_int i
  | _ -> error "num: not a float"

let opi = function
  | `Assoc ["I", `Int i] -> i
  | `Assoc ["I", `Float f] -> int_of_float f
  | _ -> error "num: not an integer"

let rec op_of_json = function
  | `List [`String "S"] -> O.Op_S
  | `List [`String "s"] -> O.Op_s
  | `List [`String "f"] -> O.Op_f
  | `List [`String "F"] -> O.Op_F
  | `List [`String "f*"] -> O.Op_f'
  | `List [`String "B"] -> O.Op_B
  | `List [`String "B*"] -> O.Op_B'
  | `List [`String "b"] -> O.Op_b
  | `List [`String "b*"] -> O.Op_b'
  | `List [`String "n"] -> O.Op_n
  | `List [`String "W"] -> O.Op_W
  | `List [`String "W*"] -> O.Op_W'
  | `List [`String "BT"] -> O.Op_BT
  | `List [`String "ET"] -> O.Op_ET
  | `List [`String "q"] -> O.Op_q
  | `List [`String "Q"] -> O.Op_Q
  | `List [`String "h"] -> O.Op_h
  | `List [`String "T*"] -> O.Op_T'
  | `List [`String "EMC"] -> O.Op_EMC
  | `List [`String "BX"] -> O.Op_BX
  | `List [`String "EX"] -> O.Op_EX
  | `List [a; b; c; d; `String "re"] -> O.Op_re (opf a, opf b, opf c, opf d)
  | `List [a; b; c; d; `String "k"] -> O.Op_k (opf a, opf b, opf c, opf d)
  | `List [a; b; `String "m"] -> O.Op_m (opf a, opf b)
  | `List [a; b; `String "l"] -> O.Op_l (opf a, opf b)
  | `List [`String s; obj; `String "BDC"] -> O.Op_BDC (s, object_of_json obj)
  | `List [`String s; `String "gs"] -> O.Op_gs s
  | `List [`String s; `String "Do"] -> O.Op_Do s
  | `List [`String s; `String "CS"] -> O.Op_CS s
  | `List [i; `String "j"] -> O.Op_j (opi i)
  | `List [a; b; c; d; e; f; `String "cm"] ->
      O.Op_cm
        {Pdftransform.a = opf a; Pdftransform.b = opf b; Pdftransform.c = opf c;
         Pdftransform.d = opf d; Pdftransform.e = opf e; Pdftransform.f = opf f}
  | `List [`List fls; y; `String "d"] -> O.Op_d (map opf fls, opf y)
  | `List [a; `String "w"] -> O.Op_w (opf a)
  | `List [a; `String "J"] -> O.Op_J (opi a)
  | `List [a; `String "M"] -> O.Op_M (opf a)
  | `List [`String s; `String "ri"] -> O.Op_ri s
  | `List [a; `String "i"] -> O.Op_i (opi a)
  | `List [a; b; c; d; e; f; `String "c"] -> O.Op_c (opf a, opf b, opf c, opf d, opf e, opf f)
  | `List [a; b; c; d; `String "v"] -> O.Op_v (opf a, opf b, opf c, opf d)
  | `List [a; b; c; d; `String "y"] -> O.Op_y (opf a, opf b, opf c, opf d)
  | `List [a; `String "Tc"] -> O.Op_Tc (opf a)
  | `List [a; `String "Tw"] -> O.Op_Tw (opf a)
  | `List [a; `String "Tz"] -> O.Op_Tz (opf a)
  | `List [a; `String "TL"] -> O.Op_TL (opf a)
  | `List [`String k; n; `String "Tf"] -> O.Op_Tf (k, opf n)
  | `List [a; `String "Tr"] -> O.Op_Tr (opi a)
  | `List [a; `String "Ts"] -> O.Op_Ts (opf a)
  | `List [a; b; `String "Td"] -> O.Op_Td (opf a, opf b)
  | `List [a; b; `String "TD"] -> O.Op_TD (opf a, opf b)
  | `List [a; b; c; d; e; f; `String "Tm"] ->
        O.Op_Tm
          {Pdftransform.a = opf a; Pdftransform.b = opf b; Pdftransform.c = opf c;
           Pdftransform.d = opf d; Pdftransform.e = opf e; Pdftransform.f = opf f}
  | `List [`String s; `String "Tj"] -> Op_Tj s
  | `List [obj; `String "TJ"] -> Op_TJ (object_of_json obj)
  | `List [`String s; `String "'"] -> Op_' s
  | `List [a; b; `String s; `String "''"] -> Op_'' (opf a, opf b, s)
  | `List [a; b; `String "d0"] -> Op_d0 (opf a, opf b)
  | `List [a; b; c; d; e; f; `String "d1"] -> Op_d1 (opf a, opf b, opf c, opf d, opf e, opf f)
  | `List [`String s; `String "cs"] -> Op_cs s 
  | `List [a; `String "G"] -> Op_G (opf a);
  | `List [a; `String "g"] -> Op_g (opf a);
  | `List [a; b; c; `String "RG"] -> Op_RG (opf a, opf b, opf c);
  | `List [a; b; c; `String "rg"] -> Op_rg (opf a, opf b, opf c);
  | `List [a; b; c; d; `String "K"] -> Op_K (opf a, opf b, opf c, opf d);
  | `List [`String s; `String "sh"] -> Op_sh s;
  | `List [`String s; `String "MP"] -> Op_MP s;
  | `List [`String s; `String "BMC"] -> Op_BMC s;
  | `List [`String s; `String "Unknown"] -> O.Op_Unknown s
  | `List [`String s; obj; `String "DP"] -> O.Op_DP (s, object_of_json obj)
  | `List [a; `String b; `String "InlineImage"] ->
      O.InlineImage (object_of_json a, Pdfio.bytes_of_string b)
  | `List torev ->
      begin match rev torev with
      | `String "SCN"::ns -> O.Op_SCN (map opf (rev ns))
      | `String "SC"::ns -> O.Op_SC (map opf (rev ns))
      | `String "sc"::ns -> O.Op_sc (map opf (rev ns))
      | `String "scn"::ns -> O.Op_scn (map opf (rev ns))
      | `String "SCNName"::`String s::ns -> O.Op_SCNName (s, map opf (rev ns))
      | `String "scnName"::`String s::ns -> O.Op_scnName (s, map opf (rev ns))
      | j ->
          Printf.eprintf "Unable to read reversed op from %s\n" (J.show (`List j));
          error "op reading failed"
      end
  | j ->
      Printf.eprintf "Unable to read op from %s\n" (J.show j);
      error "op reading failed"

and object_of_json = function
  | `Null -> P.Null
  | `Bool b -> P.Boolean b
  | `Int n -> Pdf.Indirect n
  | `String s -> P.String s
  | `List objs -> P.Array (map object_of_json objs)
  | `Assoc ["I", `Int i] -> P.Integer i
  | `Assoc ["F", `Float f] -> P.Real f
  | `Assoc ["N", `String n] -> P.Name n
  | `Assoc ["S", `List [dict; `String data]] ->
      let d' =
        P.add_dict_entry (object_of_json dict) "/Length" (P.Integer (String.length data))
      in
        P.Stream (ref (d', P.Got (Pdfio.bytes_of_string data)))
  | `Assoc ["S", `List [dict; `List parsed_ops]] ->
      Pdfops.stream_of_ops (List.map op_of_json parsed_ops)
  | `Assoc elts -> P.Dictionary (map (fun (n, o) -> (n, object_of_json o)) elts)
  | _ -> error "not recognised in object_of_json"

let pdf_of_json json =
  let objs = match json with `List objs -> objs | _ -> error "bad json top level" in
  let params = ref Pdf.Null in
  let trailerdict = ref Pdf.Null in
    let objects =
      option_map
        (function
         | `List [`Int objnum; o] ->
             begin match objnum with
             | -1 -> params := object_of_json o; None 
             | 0 -> trailerdict := object_of_json o; None
             | n when n < 0 -> None
             | n ->  Some (n, object_of_json o)
             end
         | _ -> error "json bad obj")
        objs
    in
  begin match Pdf.lookup_direct (Pdf.empty ()) "/CPDFJSONstreamdataincluded" !params with
  | Some (Pdf.Boolean false) -> error "no stream data; cannot reconstruct PDF" 
  | _ -> ()  
  end;
  let major =
    match Pdf.lookup_direct (Pdf.empty ()) "/CPDFJSONmajorpdfversion" !params with 
      Some (Pdf.Integer i) -> i | _ -> error "bad major version"
  in
  let minor =
    match Pdf.lookup_direct (Pdf.empty ()) "/CPDFJSONminorpdfversion" !params with 
      Some (Pdf.Integer i) -> i | _ -> error "bad minor version"
  in
  let root =
    match !trailerdict with Pdf.Dictionary d ->
      begin match lookup "/Root" d with
        Some (Pdf.Indirect i) -> i | _ -> error "bad root"
      end
    | _ -> error "bad root 2"
  in
  let objmap = P.pdfobjmap_empty () in
    List.iter (fun (k, v) -> Hashtbl.add objmap k (ref (P.Parsed v), 0)) objects;
    let objects =
      {P.maxobjnum = 0;
       P.parse = None;
       P.pdfobjects = objmap;
       P.object_stream_ids = Hashtbl.create 0}
    in
      {P.major;
       P.minor;
       P.root;
       P.objects;
       P.trailerdict = !trailerdict;
       P.was_linearized = false;
       P.saved_encryption = None}

let mkfloat f = `Assoc [("F", `Float f)]
let mkint i = `Assoc [("I", `Int i)]
let mkname n = `Assoc [("N", `String n)]

let rec json_of_object pdf fcs no_stream_data pcs = function
  | P.Null -> `Null
  | P.Boolean b -> `Bool b
  | P.Integer i -> mkint i
  | P.Real r -> mkfloat r
  | P.String s -> `String s
  | P.Name n -> mkname n
  | P.Array objs -> `List (map (json_of_object pdf fcs no_stream_data pcs) objs)
  | P.Dictionary elts ->
      iter
        (function
            ("/Contents", P.Indirect i) ->
               begin match Pdf.lookup_obj pdf i with
               | Pdf.Array is -> iter (function Pdf.Indirect i -> fcs i | _ -> ()) is
               | _ -> fcs i
               end
          | ("/Contents", P.Array elts) -> iter (function P.Indirect i -> fcs i | _ -> ()) elts
          | _ -> ())
        elts;
      `Assoc (map (fun (k, v) -> (k, json_of_object pdf fcs no_stream_data pcs v)) elts)
  | P.Stream ({contents = (P.Dictionary dict as d, stream)} as mut) as thestream ->
      P.getstream thestream;
      let str =
        match P.lookup_direct pdf "/FunctionType" d, pcs with
        | Some _, true ->
            Pdfcodec.decode_pdfstream_until_unknown pdf thestream;
            begin match !mut with (_, P.Got b) -> Pdfio.string_of_bytes b | _ -> error "/FunctionType: failure: decomp" end
        | _ ->
            if no_stream_data then "<<stream data elided>>" else
              match !mut with (_, P.Got b) -> Pdfio.string_of_bytes b | _ -> error "failure: toget"
      in
        json_of_object pdf fcs no_stream_data pcs (P.Dictionary [("S", P.Array [P.Dictionary dict; P.String str])])
  | P.Stream _ -> error "error: stream with not-a-dictionary"
  | P.Indirect i ->
      begin match P.lookup_obj pdf i with
      | P.Stream {contents = (P.Dictionary dict as d, _)} ->
          begin match P.lookup_direct pdf "/Subtype" d with
          | Some (P.Name "/Form") -> fcs i
          | _ -> ()
          end
      | _ -> ()
      end;
      `Int i

let json_of_op pdf no_stream_data = function
  | O.Op_S -> `List [`String "S"]
  | O.Op_s -> `List [`String "s"]
  | O.Op_f -> `List [`String "f"]
  | O.Op_F -> `List [`String "F"]
  | O.Op_f' ->`List [`String "f*"]
  | O.Op_B -> `List [`String "B"]
  | O.Op_B' -> `List [`String "B*"]
  | O.Op_b -> `List [`String "b"]
  | O.Op_b' -> `List [`String "b*"]
  | O.Op_n -> `List [`String "n"]
  | O.Op_W -> `List [`String "W"]
  | O.Op_W' -> `List [`String "W*"]
  | O.Op_BT -> `List [`String "BT"]
  | O.Op_ET -> `List [`String "ET"]
  | O.Op_q -> `List [`String "q"]
  | O.Op_Q -> `List [`String "Q"]
  | O.Op_h -> `List [`String "h"]
  | O.Op_T' -> `List [`String "T*"]
  | O.Op_EMC -> `List [`String "EMC"]
  | O.Op_BX -> `List [`String "BX"]
  | O.Op_EX -> `List [`String "EX"]
  | O.Op_re (a, b, c, d) ->
      `List [mkfloat a; mkfloat b; mkfloat c; mkfloat d; `String "re"]
  | O.Op_k (c, m, y, k) ->
      `List [mkfloat c; mkfloat m; mkfloat y; mkfloat k; `String "k"]
  | O.Op_m (a, b) -> `List [mkfloat a; mkfloat b; `String "m"]
  | O.Op_l (a, b) -> `List [mkfloat a; mkfloat b; `String "l"]
  | O.Op_BDC (s, obj) -> `List [`String s; json_of_object pdf (fun _ -> ()) no_stream_data false obj; `String "BDC"]
  | O.Op_gs s -> `List [`String s; `String "gs"]
  | O.Op_Do s -> `List [`String s; `String "Do"]
  | O.Op_CS s -> `List [`String s; `String "CS"]
  | O.Op_SCN fs -> `List ((map (fun x -> mkfloat x) fs) @ [`String "SCN"])
  | O.Op_j j -> `List [mkint j; `String "j"] 
  | O.Op_cm t ->
      `List
        [mkfloat t.Pdftransform.a; mkfloat t.Pdftransform.b; mkfloat t.Pdftransform.c;
         mkfloat t.Pdftransform.d; mkfloat t.Pdftransform.e; mkfloat t.Pdftransform.f;
         `String "cm"]
  | O.Op_d (fl, y) ->
      `List [`List (map (fun x -> mkfloat x) fl); mkfloat y; `String "d"]
  | O.Op_w w -> `List [mkfloat w; `String "w"]
  | O.Op_J j -> `List [mkint j; `String "J"]
  | O.Op_M m -> `List [mkfloat m; `String "M"]
  | O.Op_ri s -> `List [`String s; `String "ri"]
  | O.Op_i i -> `List [mkint i; `String "i"]
  | O.Op_c (a, b, c, d, e, k) ->
      `List
        [mkfloat a; mkfloat b; mkfloat c;
         mkfloat d; mkfloat e; mkfloat k; `String "c"]
  | O.Op_v (a, b, c, d) ->
      `List
        [mkfloat a; mkfloat b; mkfloat c;
         mkfloat d; `String "v"]
  | O.Op_y (a, b, c, d) ->
      `List
        [mkfloat a; mkfloat b; mkfloat c;
         mkfloat d; `String "y"]
  | O.Op_Tc c -> `List [mkfloat c; `String "Tc"]
  | O.Op_Tw w -> `List [mkfloat w; `String "Tw"]
  | O.Op_Tz z -> `List [mkfloat z; `String "Tz"]
  | O.Op_TL l -> `List [mkfloat l; `String "TL"]
  | O.Op_Tf (k, s) -> `List [`String k; mkfloat s; `String "Tf"]
  | O.Op_Tr i -> `List [mkint i; `String "Tr"]
  | O.Op_Ts k -> `List [mkfloat k; `String "Ts"]
  | O.Op_Td (k, k') -> `List [mkfloat k; mkfloat k'; `String "Td"]
  | O.Op_TD (k, k') -> `List [mkfloat k; mkfloat k'; `String "TD"]
  | O.Op_Tm t ->
      `List
        [mkfloat t.Pdftransform.a; mkfloat t.Pdftransform.b; mkfloat t.Pdftransform.c;
         mkfloat t.Pdftransform.d; mkfloat t.Pdftransform.e; mkfloat t.Pdftransform.f;
         `String "Tm"]
  | O.Op_Tj s -> `List [`String s; `String "Tj"]
  | O.Op_TJ pdfobject -> `List [json_of_object pdf (fun _ -> ()) no_stream_data false pdfobject; `String "TJ"]
  | O.Op_' s -> `List [`String s; `String "'"]
  | O.Op_'' (k, k', s) -> `List [mkfloat k; mkfloat k'; `String s; `String "''"]
  | O.Op_d0 (k, k') -> `List [mkfloat k; mkfloat k'; `String "d0"]
  | O.Op_d1 (a, b, c, d, e, k) ->
      `List
        [mkfloat a; mkfloat b; mkfloat c;
         mkfloat d; mkfloat e; mkfloat k; `String "d1"]
  | O.Op_cs s -> `List [`String s; `String "cs"]
  | O.Op_SC fs -> `List (map (fun x -> mkfloat x) fs @ [`String "SC"])
  | O.Op_sc fs -> `List (map (fun x -> mkfloat x) fs @ [`String "sc"])
  | O.Op_scn fs -> `List (map (fun x -> mkfloat x) fs @ [`String "scn"])
  | O.Op_G k -> `List [mkfloat k; `String "G"]
  | O.Op_g k -> `List [mkfloat k; `String "g"]
  | O.Op_RG (r, g, b) -> `List [mkfloat r; mkfloat g; mkfloat b; `String "RG"]
  | O.Op_rg (r, g, b) -> `List [mkfloat r; mkfloat g; mkfloat b; `String "rg"]
  | O.Op_K (c, m, y, k) -> `List [mkfloat c; mkfloat m; mkfloat y; mkfloat k; `String "K"]
  | O.Op_sh s -> `List [`String s; `String "sh"]
  | O.Op_MP s -> `List [`String s; `String "MP"]
  | O.Op_BMC s -> `List [`String s; `String "BMC"]
  | O.Op_Unknown s -> `List [`String s; `String "Unknown"]
  | O.Op_SCNName (s, fs) ->
      `List (map (fun x -> mkfloat x) fs @ [`String s; `String "SCNName"])
  | O.Op_scnName (s, fs) ->
      `List (map (fun x -> mkfloat x) fs @ [`String s; `String "scnName"])
  | O.InlineImage (dict, data) ->
      `List [json_of_object pdf (fun _ -> ()) no_stream_data false dict; `String (Pdfio.string_of_bytes data); `String "InlineImage"]
  | O.Op_DP (s, obj) ->
      `List [`String s; json_of_object pdf (fun _ -> ()) no_stream_data false obj; `String "DP"]

(* parse_stream needs pdf and resources. These are for lexing of inline images,
 * looking up the colourspace. We do not need to worry about inherited
 * resources, though? For now, don't worry about inherited resources: check in
 * PDF standard. *)
let parse_content_stream pdf resources bs =
  let ops = O.parse_stream pdf resources [bs] in
    `List (map (json_of_op pdf false) ops)

(* We need to make sure each page only has one page content stream. Otherwise,
   if not split on op boundaries, each one would fail to parse on its own. The
   caller should really only do this on otherwise-failing files, since it could
   blow up any shared content streams *)
let do_precombine_page_content pdf =
  let pages' =
    map
      (fun page ->
         match page.Pdfpage.content with
           [] | [_] -> page
         | _ ->
           let operators =
             Pdfops.parse_operators pdf page.Pdfpage.resources page.Pdfpage.content
           in
             {page with Pdfpage.content = [Pdfops.stream_of_ops operators]}
      )
      (Pdfpage.pages_of_pagetree pdf)
  in
    Pdfpage.change_pages true pdf pages'

let json_of_pdf
  ~parse_content ~no_stream_data ~decompress_streams ~precombine_page_content
  pdf
=
  let pdf = if parse_content && precombine_page_content then do_precombine_page_content pdf else pdf in
  if decompress_streams then
    Pdf.objiter (fun _ obj -> Pdfcodec.decode_pdfstream_until_unknown pdf obj) pdf;
  Pdf.remove_unreferenced pdf;
  let trailerdict = (0, json_of_object pdf (fun x -> ()) no_stream_data false pdf.P.trailerdict) in
  let parameters =
    (-1, json_of_object pdf (fun x -> ()) false false
      (Pdf.Dictionary [("/CPDFJSONformatversion", Pdf.Integer 2);
                       ("/CPDFJSONcontentparsed", Pdf.Boolean parse_content);
                       ("/CPDFJSONstreamdataincluded", Pdf.Boolean (not no_stream_data));
                       ("/CPDFJSONmajorpdfversion", Pdf.Integer pdf.Pdf.major);
                       ("/CPDFJSONminorpdfversion", Pdf.Integer pdf.Pdf.minor);
                      ]))
  in
  let content_streams = ref [] in
  let fcs n =
    content_streams := n::!content_streams;
    if parse_content then Pdfcodec.decode_pdfstream_until_unknown pdf (P.lookup_obj pdf n)
  in
  let pairs =
    let ps = ref [] in
      P.objiter
        (fun i pdfobj ->
          ps := (i, json_of_object pdf fcs no_stream_data parse_content pdfobj)::!ps)
        pdf;
      parameters::trailerdict::!ps
  in
    let pairs_parsed =
      if not parse_content then pairs else
        map
          (fun (objnum, obj) ->
             if mem objnum !content_streams then
               begin match obj with
               | `Assoc ["S", `List [dict; `String _]] ->
                   (* FIXME Proper resources here for reasons explained above? *)
                   let streamdata =
                     match P.lookup_obj pdf objnum with
                     | P.Stream {contents = (_, P.Got b)} -> b
                     | _ -> error "JSON: stream not decoded"
                   in
                     (objnum, `Assoc ["S", `List [dict; parse_content_stream pdf (P.Dictionary []) streamdata]])
               | _ -> error "json_of_pdf: stream parsing inconsistency"
               end
             else
               (objnum, obj))
          pairs
    in
      `List
        (map
          (fun (objnum, jsonobj) -> `List [`Int objnum; jsonobj])
          pairs_parsed)

let to_output o ~parse_content ~no_stream_data ~decompress_streams ~precombine_page_content pdf =
  let json = json_of_pdf ~parse_content ~no_stream_data ~decompress_streams ~precombine_page_content pdf in
    match o.Pdfio.out_caml_channel with
    | Some ch -> J.pretty_to_channel ch json
    | None -> o.Pdfio.output_string (J.pretty_to_string json)

let of_input i =
  try
    match i.Pdfio.caml_channel with
    | Some ch -> pdf_of_json (J.from_channel ch)
    | None -> 
        let content = Pdfio.string_of_bytes (Pdfio.bytes_of_input i 0 (i.Pdfio.in_channel_length)) in
          pdf_of_json (J.from_string content)
  with
    e -> error (Printexc.to_string e)
