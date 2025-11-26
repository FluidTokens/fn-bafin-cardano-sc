pub type Config {
  // if this is the policy Id of the script, it's already available as the key in the registry.
  // also it should be unmodifiable.
  issuance_logic_script_hash: ByteArray,
}
