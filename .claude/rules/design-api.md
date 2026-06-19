# design-api

## Table of Contents

1. [Introduction](#introduction)
2. [Rule #0: DON'T get pedantic](#rule-0-dont-get-pedantic)
3. [Rule #1: DO use plural nouns for collections](#rule-1-do-use-plural-nouns-for-collections)
4. [Rule #2: DON'T add unnecessary path segments](#rule-2-dont-add-unnecessary-path-segments)
5. [Rule #3: DON'T add .json or other extensions to the url](#rule-3-dont-add-json-or-other-extensions-to-the-url)
6. [Rule #4: DON'T return arrays as top level responses](#rule-4-dont-return-arrays-as-top-level-responses)
7. [Rule #5: DON'T return map structures](#rule-5-dont-return-map-structures)
8. [Rule #6: DO use strings for all identifiers](#rule-6-do-use-strings-for-all-identifiers)
9. [Rule #7: DO prefix your identifiers](#rule-7-do-prefix-your-identifiers)
10. [Rule #8: DON'T use 404 to indicate "not found"](#rule-8-dont-use-404-to-indicate-not-found)
11. [Rule #9: BE consistent](#rule-9-be-consistent)
12. [Rule #10: DO use a structured error format](#rule-10-do-use-a-structured-error-format)
13. [Rule #11: DO provide idempotence mechanisms](#rule-11-do-provide-idempotence-mechanisms)
14. [Rule #12: DO use ISO8601 strings for timestamps](#rule-12-do-use-iso8601-strings-for-timestamps)

## Introduction

Best practices for designing pragmatic, long-lived REST APIs, adapted from Jeff
Schnitzer's [_How to (and how not to) design REST APIs_](https://github.com/stickfigure/blog/wiki/How-to-(and-how-not-to)-design-REST-APIs).
The guiding theme is backwards compatibility: a great API outlives its
implementation, its database, and often the company that built it. Design every
endpoint so that future changes can be *additive* rather than breaking.

These are conventions, not laws. But violating them tends to be a leading
indicator that an API "will have rough edges".

---

## **Rule #0: DON'T get pedantic**

Most developers today understand "REST" as an HTTP-based API with noun-based
URLs. The term originally meant something slightly different, but language
changes. Don't argue about what is or isn't "really" REST — focus on building
pragmatic, useful APIs that client developers enjoy consuming.

**[⬆ back to top](#table-of-contents)**

## **Rule #1: DO use plural nouns for collections**

It's an arbitrary convention, but it's well-established, and client developers
already expect it. There's no technical reason one is better — that's exactly
why you should stick to what everyone expects.

```
# GOOD
GET /products              # get all the products
GET /products/{product_id} # get one product

# BAD
GET /product/{product_id}
```

**[⬆ back to top](#table-of-contents)**

## **Rule #2: DON'T add unnecessary path segments**

A common mistake is encoding your relational model into the URL structure. If an
identifier is globally unique, it doesn't need a parent segment.

```
# GOOD
GET /v3/application/listings/{listing_id}

# BAD
PATCH /v3/application/shops/{shop_id}/listings/{listing_id}
GET   /v3/application/shops/{shop_id}/listings/{listing_id}/properties
PUT   /v3/application/shops/{shop_id}/listings/{listing_id}/properties/{property_id}
```

The `{listing_id}` is globally unique, so `{shop_id}` is just clutter — and it
breaks when the invariant changes (e.g. a listing moves to a different shop, or
is listed in multiple shops). Use compound URLs only when you genuinely have a
compound key:

```
# When {option_id} is NOT globally unique
GET /listings/{listing_id}/options/{option_id}
```

**[⬆ back to top](#table-of-contents)**

## **Rule #3: DON'T add .json or other extensions to the url**

URLs are resource identifiers, not representations.

- Adding a representation to the URL means there's no canonical URL for a "thing".
- "JSON" isn't even a complete representation spec (what transfer encoding?).
- HTTP already has `Accept`, `Accept-Charset`, `Accept-Encoding`, `Accept-Language`
  to negotiate representations.
- Trailing boilerplate annoys client authors.
- JSON should be the default anyway.

```
# GOOD
GET /products/{product_id}

# BAD
GET /products/{product_id}.json
```

Return JSON by default; let clients negotiate anything else via standard HTTP headers.

**[⬆ back to top](#table-of-contents)**

## **Rule #4: DON'T return arrays as top level responses**

The top-level response from an endpoint should always be an object, never an array.

```
# GOOD
GET /things returns:
{ "data": [ { ...thing1... }, { ...thing2... } ] }

# BAD
GET /things returns:
[ { ...thing1... }, { ...thing2... } ]
```

Objects let you make additive, backwards-compatible changes. The obvious example
is pagination: you can add `totalCount` or `hasMore` fields and old clients keep
working. A top-level array forces you to create a whole new endpoint.

**[⬆ back to top](#table-of-contents)**

## **Rule #5: DON'T return map structures**

Return an array of objects, not a keyed map.

```
# BAD
GET /things returns:
{
    "KEY1": { "id": "KEY1", "foo": "bar" },
    "KEY2": { "id": "KEY2", "foo": "baz" },
    "KEY3": { "id": "KEY3", "foo": "bat" }
}

# GOOD (also applies Rule #4)
GET /things returns:
{
    "data": [
        { "id": "KEY1", "foo": "bar" },
        { "id": "KEY2", "foo": "baz" },
        { "id": "KEY3", "foo": "bat" }
    ]
}
```

Maps are bad because: the key duplicates data on the wire, dynamic keys are
painful in typed languages, and your "natural" key may change over time — and the
only way to migrate is to break backwards compatibility.

### Exception to the no-map rule

Simple key/value pairs (like Stripe's `metadata`) are fine:

```
# OK
{ "key1": "value1", "key2": "value2" }
```

If the values are more than simple strings, prefer arrays of objects instead.

**[⬆ back to top](#table-of-contents)**

## **Rule #6: DO use strings for all identifiers**

Always use strings for identifiers, even when your internal (database) type is
numeric. Just stringify the number.

```
# BAD
{ "id": 123 }

# GOOD
{ "id": "123" }
```

A great API outlasts its implementation. Strings survive platform rewrites,
database merges (conflicting ID ranges), and let you encode version info or
composite keys later. Numeric IDs put a straitjacket on future developers. Bonus:
clients in typed languages never have to wonder which numeric type to use.

**[⬆ back to top](#table-of-contents)**

## **Rule #7: DO prefix your identifiers**

Make different ID types self-describing so they're instantly distinguishable.

```
# GOOD (Stripe-style two-letter prefixes)
in_1MVpWEJVZPfyS2HyRgVDkwiZ
cus_NffrFeUfNV2Hib

# BAD (opaque, ambiguous)
1469358604360
```

The format doesn't matter as long as IDs are 1) visually distinct and 2) never
change. This dramatically reduces support load — you can instantly tell an
"order line item ID" from an "invoice item line item ID".

**[⬆ back to top](#table-of-contents)**

## **Rule #8: DON'T use 404 to indicate "not found"**

A 404 for a missing entity is ambiguous: it can also come from a misconfigured
client, proxy, load balancer, or server routing table. The client can't tell
"the thing doesn't exist" from "something went wrong" — almost like a 500.

```
# BAD — ambiguous with infrastructure failures
GET /things/{thing_id}   ->   404 NOT FOUND

# GOOD — pick a code that means "I understood you, but I don't have it"
GET /things/{thing_id}   ->   410 GONE
```

This matters for distributed consistency. Queues are at-least-once, so a
`DELETE` job may retry; it must treat "not found" as success. If a stray 404 from
your stack is treated as success, the delete silently fails to propagate. Use a
distinct 4xx (the author uses `410 GONE`) so clients can reliably interpret it.
`DELETE` returning `200`/`204` for a nonexistent thing is also acceptable.

**[⬆ back to top](#table-of-contents)**

## **Rule #9: BE consistent**

Keep field names consistent across objects with similar meanings. Shopify's REST
API infamously has ~6 subtly different Address schemas — some have `name`, some
only `first_name`/`last_name`, some add `country_name` or `country_code`, some
drop fields entirely. This is maddening and a reliable source of null-pointer
bugs. If you work in a dynamic language like Ruby or Python, try extra hard.

**[⬆ back to top](#table-of-contents)**

## **Rule #10: DO use a structured error format**

Establish one standard error shape up front — especially for systems with
multiple layers of services. Model it roughly like an exception, with a nested
`cause`:

```
{
  "message": "You do not have permission to access this resource",
  "type": "Unauthorized",
  "types": ["Unauthorized", "Security"],
  "cause": { ...recurse for any nested exceptions... }
}
```

A nested cause lets each service wrap and rethrow errors:
`ServiceAlpha -> ServiceBravo -> ServiceCharlie -> ServiceDelta`. If Delta fails,
Alpha can return or log the complete chain including the root cause — much easier
to debug than combing through four systems' logs.

**[⬆ back to top](#table-of-contents)**

## **Rule #11: DO provide idempotence mechanisms**

`GET`, `PUT`, and `DELETE` are already expected to be idempotent. `POST`/create
is not — and because the network is unreliable (the Two Generals' Problem), a
client that times out can't tell whether its order succeeded. Retrying risks
duplicates; not retrying risks lost orders. Provide a mechanism for exactly-once
behavior.

**Good option — idempotency key / client reference ID** (enforce uniqueness server-side):

```
POST /v1/customers
Idempotency-Key: blahblahblahblah
{ "name": "Bob Dobbs" }
```

**Good option — let the client pick IDs** (the chosen ID is the idempotency key):

```
# Client picks the id
POST /things
{ "id": "mything1" }

# The id can now be used
GET /things/mything1
```

**On conflict**, return `409 CONFLICT` and include the existing ID so the client
can record it (make the key a string — see Rule #6):

```
POST /things
{ "idempotency_key": "blahblahblah", ...etc... }

# Response 409 CONFLICT
{ "message": "This is a duplicate", "old_id": "THG1234" }
```

TL;DR — pick *something*: have the client submit an idempotency key with each
create, store it with a unique constraint, return `409 CONFLICT` on violation,
and include the original ID in the response body.

**[⬆ back to top](#table-of-contents)**

## **Rule #12: DO use ISO8601 strings for timestamps**

Use ISO8601 strings, not numbers like milliseconds-since-epoch. Human readability
matters — a person can spot that `2023-12-21T11:17:12.34Z` is in the future;
nobody can eyeball `1703157432340`. All timestamps should be UTC (`Z`).

```
# GOOD
{ "createdAt": "2023-12-21T11:17:12.34Z" }

# BAD
{ "createdAt": 1703157432340 }
```

### Rule #12a: Use ISO8601 for *all* date/time-related values

ISO8601 also standardizes zoneless local dates and times, durations, and
intervals. Use them.

### Rule #12b: DON'T trust your language/platform defaults

Many platforms don't emit ISO8601 by default, and the default format often varies
by locale or timezone. Always verify your API's output. There's always a way to
force ISO8601 (e.g. JavaScript's `Date.toISOString()`).

**[⬆ back to top](#table-of-contents)**
