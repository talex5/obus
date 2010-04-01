(*
 * oBus_property.mli
 * -----------------
 * Copyright : (c) 2010, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *
 * This file is a part of obus, an ocaml implementation of D-Bus.
 *)

(** D-Bus properties *)

(** This module offers a convenient way to deal with D-Bus
    properties. It allows to read/write the contents of a property,
    and, when possible, to monitor it. *)

(** {6 Types} *)

type ('a, 'access) t
  (** Type of a property holding a value of type ['a]. ['access] is
      the access mode of the property. *)

type 'a r = ('a, [ `readable ]) t
    (** Type of read-only properties *)

type 'a w = ('a, [ `writable ]) t
    (** Type of write-only properties *)

type 'a rw = ('a, [ `readable | `writable ]) t
    (** Type of read and write properties *)

type 'a access
  (** Type of access modes *)

val readable : [ `readable ] access
  (** Access mode for readable properties *)

val writable : [ `writable ] access
  (** Access mode for writable properties *)

val readable_writable : [ `readable | `writable ] access
  (** Access mode for readable and writable properties *)

(** {6 Operation on properties} *)

val get : ('a, [> `readable ]) t -> 'a Lwt.t
  (** Read the contents of a property *)

val set : ('a, [> `writable ]) t -> 'a -> unit Lwt.t
  (** Write the contents of a property *)

(** {6 Monitoring} *)

(** Lots of D-Bus services notifies other applications with a D-Bus
    signal when one or more properties of an object change. In this
    case it is possible to monitor the contents of a property.

    Note that when at least one property of an interface is monitored,
    obus will keep a local state of all the properties of the
    interface, until all signals (see {!contents}) are garbage
    collected, or disconnected with {!disconnect}.
*)

val contents : ('a, [> `readable ]) t -> 'a React.signal Lwt.t
  (** [contents property] returns the signal holding the current
      contents of [property] *)

(** {6 Property creation} *)

val make :
  connection : OBus_connection.t ->
  ?owner : OBus_name.bus ->
  path : OBus_path.t ->
  interface : OBus_name.interface ->
  member : OBus_name.member ->
  access : 'access access ->
  ?changed : OBus_name.member ->
  ('a, _) OBus_type.cl_single -> ('a, 'access) t
  (** [make ~connection ?sender ~path ~interface ~member ~access
      ?changed typ] creates a property with the given interface and
      member.

      [owner] is the name of the peer owning the property.

      [changed] is the name of a signal of the interface which is used
      to notify that one or more properties have changed. Usually it
      is called [Changed] or [PropertiesChanged]. *)

val dyn_make :
  connection : OBus_connection.t ->
  ?owner : OBus_name.bus ->
  path : OBus_path.t ->
  interface : OBus_name.interface ->
  member : OBus_name.member ->
  access : 'access access ->
  ?changed : OBus_name.member -> unit -> (OBus_value.single, 'access) t
  (** Same as {!make} but using dynamically typed values *)

(** {6 Receving all properties} *)

val get_all :
  connection : OBus_connection.t ->
  ?owner : OBus_name.bus ->
  path : OBus_path.t ->
  interface : OBus_name.interface ->
  unit -> (string * OBus_value.single) list Lwt.t
