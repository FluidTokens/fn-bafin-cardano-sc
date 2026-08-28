//Asset name of the global state NFT
pub const global_state_asset_name = "GlobalState"

//Linked list constants (matching v1.2.0 defaults for on-chain compatibility)
pub const linked_list_root_key = #""

pub const linked_list_node_key_prefix = "Node"

pub const linked_list_node_key_prefix_length = 4

// Indexes of the fields in the registry node which are used to verify the correctness of the registry node 
// and extract the hashed params for deriving the issuance policy id
// It is derived by index to allow the extension of the registry node in the future without breaking the logic of deriving the issuance policy id from the registry node
pub const minting_logic_script_registry_node_index = 2

pub const transfer_logic_script_registry_node_index = 3

pub const third_party_transfer_logic_script_registry_node_index = 4

// Added in CIP-113 v0.4.0. `VerificationKey(#"")` (core's `empty_vkey`) means
// unfracking is FORBIDDEN for the policy — the least-permission default. This
// repo ships no unfracking hook, so registration must leave it unset.
pub const unfracking_logic_script_registry_node_index = 5

// The GlobalState NFT policy the registry node declares for this token. v0.4.0
// pushed it from 5 to 6 when `unfracking_logic_script` was inserted ahead of it.
pub const global_state_cs_registry_node_index = 6

// ============================================================================
// Datum growth caps (defence in depth)
// ============================================================================
// Each bound is enforced both at genesis (`sanitise_initial_datum`) and on
// every spend branch able to grow the corresponding field. All three are
// tunable at compile time and sit far below the ~16 KiB transaction size
// limit: they exist to keep a single GlobalState datum from growing large
// enough to threaten the continuing control UTxO's own inclusion in a future
// transaction, not to reflect any specific operational ceiling.

// Maximum number of entries the trusted-entity list may hold.
pub const max_trusted_entities = 64

// Maximum serialised (CBOR) size, in bytes, of the `security_info` field.
pub const max_security_info_bytes = 4096

// Maximum serialised (CBOR) size, in bytes, of a single trusted entity's
// metadata value.
pub const max_trusted_entity_metadata_bytes = 512

// ============================================================================
// CIP-68 protected asset-name prefixes
// ============================================================================
// CIP-67 encodes an asset-name label as four bytes: `0x00 | label(20 bits) |
// checksum(8 bits) | 0x00`. A name carrying one of the prefixes below is
// METADATA, not value — it is exempt from the supply cap and from the denylist
// and KYC gates, and it must therefore be prevented from moving like value.
//
// Only `(100)`, the reference token, belongs here. The USER-token labels —
// `(222)` `#"000de140"`, `(333)` `#"0014df10"`, `(444)` `#"001bc280"` — must
// NEVER be listed: the security token itself carries one of them, and
// protecting it would refuse every seizure and every ordinary transfer.
// `verify_registration_structure` asserts that `security_asset_name` does not
// carry a protected prefix, so that misconfiguration fails closed at
// registration rather than silently later.
pub const protected_prefixes: List<ByteArray> =
  [
    // CIP-67 label (100) — the CIP-68 reference / metadata token.
    #"000643b0",
  ]

/// Length of every entry in `protected_prefixes`, in bytes.
///
/// CIP-67 fixes an asset-name label at four bytes, so `cip68.is_protected` takes
/// that many rather than measuring each prefix on every comparison — the same
/// reason `linked_list_node_key_prefix_length` sits beside its prefix above. It
/// runs once per token of the issuance policy per output on the transfer path,
/// so the saved `bytearray.length` is not free.
///
/// The cost of fixing it: an entry of any OTHER length would be compared against
/// a four-byte slice, match nothing, and leave that token silently unprotected.
/// `protected_prefixes_are_all_the_fixed_length` in `lib/cip68.ak` is the
/// tripwire — add a wrong-length prefix and the test fails instead of the
/// security property.
pub const protected_prefix_length = 4
