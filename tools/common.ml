(*
 * common.ml
 * ---------
 * Copyright : (c) 2008, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *
 * This file is a part of obus, an ocaml implemtation of dbus.
 *)

open Format
open OBus_introspect
open Term

(***** Printing of module interfaces *****)

let translator : [ `ocaml | `haskell ] ref = ref `ocaml

let plid pp str = match !translator with
  | `ocaml -> pp_print_string pp (OBus_name.ocaml_lid str)
  | `haskell -> pp_print_string pp (OBus_name.haskell_lid str)

let puid pp str = match !translator with
  | `ocaml -> pp_print_string pp (OBus_name.ocaml_uid str)
  | `haskell -> pp_print_string pp (OBus_name.haskell_uid str)

let unit = term "unit" []

let if_term_of_args = List.map (fun (name, typ) -> interf_term_of_single typ)

let print_proxy_interf pp (name, content, annots) =
  let p fmt = fprintf pp fmt in
  p "module %a : sig\n" puid name;
  p "  type t = OBus_proxy.t\n";
  List.iter begin function
    | Method(name, ins, outs, annots) ->
        p "  val %a : %a\n" plid name
          (print_func (term "Lwt.t" [tuple (if_term_of_args  outs)]))
          (term "t" [] :: if_term_of_args ins)
    | Signal(name, args, annots) ->
        p "  val %a : %a\n" plid name
          (print_term true)
          (term "OBus_signal.t"
             [match args with
                | [] -> unit
                | _ -> tuple (if_term_of_args args)])
    | Property(name, typ, access, annots) ->
        p "  val %a : %a\n" plid name
          (print_term true)
          (term "OBus_property.t"
             [interf_term_of_single typ;
              term
                (match access with
                   | Read -> "[ `readable ]"
                   | Write -> "[ `writable ]"
                   | Read_write -> "[ `readable | `writable ]") []])
  end content;
  p "end\n"
