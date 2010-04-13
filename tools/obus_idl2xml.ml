(*
 * obus_idl2xml.ml
 * ---------------
 * Copyright : (c) 2010, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *
 * This file is a part of obus, an ocaml implementation of D-Bus.
 *)

let module M = Camlp4OCamlParser.Make(Camlp4OCamlRevisedParser.Make(Camlp4.PreCast.Syntax)) in ()

let usage_message =
  Printf.sprintf "Usage: %s <options> <file>\n\
                  Generate a D-Bus introspection file from an obus IDL file.\n\
                  options are:"
    (Filename.basename Sys.argv.(0))

let output = ref ""

let args = [
  "-o", Arg.Set_string output, "<file-name> output file name";
]

let () =
  let sources = ref [] in
  Arg.parse args (fun s -> sources := s :: !sources) usage_message;

  let source =
    match !sources with
      | [s] -> s
      | _ -> Arg.usage args usage_message; exit 1
  in
  let destination =
    match !output with
      | "" ->
          (try
             Filename.chop_extension source
           with Invalid_argument _ ->
             source) ^ ".xml"
      | name ->
          name
  in

  let oc = open_out destination in
  try
    OBus_introspect.output
      (Xmlm.make_output ~nl:true ~indent:(Some 2) (`Channel oc))
      (Utils.IFSet.elements (Utils.parse_idl source), []);
    close_out oc;
    Printf.printf "file \"%s\" written\n" destination
  with exn ->
    Format.eprintf "@[<v0>%a@]@." Camlp4.ErrorHandler.print exn