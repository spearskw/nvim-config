;; extends
;;
;; Augments aerial.nvim's built-in JSON query (which only captures pairs whose
;; value is an OBJECT — e.g. "metadata"). These add:
;;   1. Array-valued keys  → containers        ("predictions", "lockers")
;;   2. Objects inside an array → leaf entries, labelled by a signature field
;;      so a prediction shows as its hub_name and a locker as its locker_number.
;; Add field names to the #any-of? list to teach it about other array shapes.

; "predictions": [ … ]  /  "lockers": [ … ]  → a navigable container
(pair
  key: (string (string_content) @name)
  value: (array) @symbol
  (#set! "kind" "Array")) @start

; each { … } element of an array, named by its most identifying field
(array
  (object
    (pair
      key: (string (string_content) @_key)
      value: (string (string_content) @name))
    (#any-of? @_key "hub_name" "locker_number" "name" "id" "title")) @symbol @start
  (#set! "kind" "Object"))
