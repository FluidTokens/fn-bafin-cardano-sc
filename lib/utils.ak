use aiken/builtin
use aiken/collection/dict
use aiken/collection/list.{length}
use aiken/collection/pairs
use aiken/crypto.{Blake2b_224, Hash, VerificationKeyHash}
use aiken/interval.{Finite}
use aiken/math/rational.{Rational}
use cardano/address.{
  Address, Credential, Inline, Script, StakeCredential, VerificationKey,
}
use cardano/assets.{
  AssetName, PolicyId, Value, policies, quantity_of, to_dict, tokens,
}
use cardano/transaction.{
  Input, Output, OutputReference, ScriptPurpose, Spend, Transaction,
}

pub fn must_be_signed_by_stake_credential(
  transaction: Transaction,
  stakeCredential: StakeCredential,
) {
  expect Inline(credential) = stakeCredential
  expect VerificationKey(hash) = credential
  list.has(transaction.extra_signatories, hash)
}

pub fn is_output_to_sc(output: Output, scHash: ByteArray) -> Bool {
  when output.address.payment_credential is {
    Script(hash) -> hash == scHash
    _ -> False
  }
}

pub fn get_outputs_to_sc(
  outputs: List<Output>,
  scHash: ByteArray,
) -> List<Output> {
  list.filter(outputs, fn(output) { is_output_to_sc(output, scHash) })
}

pub fn get_inputs_from_sc(inputs: List<Input>, scHash: ByteArray) -> List<Input> {
  list.filter(inputs, fn(input) { is_output_to_sc(input.output, scHash) })
}

pub fn is_script_output(output: Output) -> Bool {
  when output.address.payment_credential is {
    Script(_) -> True
    _ -> False
  }
}

pub fn only_one_sc_used(inputs: List<Input>, scHash: ByteArray) {
  let inputsWithDatum =
    list.filter(inputs, fn(input) { is_script_output(input.output) })
  length(get_inputs_from_sc(inputs, scHash)) == length(inputsWithDatum)
}

pub fn must_be_signed_by(transaction: Transaction, address: Address) {
  expect VerificationKey(hash) = address.payment_credential
  list.has(transaction.extra_signatories, hash)
}

pub fn address_in_signatures(
  extra_signatories: List<VerificationKeyHash>,
  address: Address,
) {
  expect VerificationKey(hash) = address.payment_credential
  list.has(extra_signatories, hash)
}

pub fn get_own_hash(output_reference: OutputReference, txInputs: List<Input>) {
  expect Some(input) =
    list.find(txInputs, fn(x) { x.output_reference == output_reference })

  expect Script(hash) = input.output.address.payment_credential
  hash
}

/// Returns the quantity of all tokens with the policyId
pub fn quantity_of_policy_id(value: Value, policyId: PolicyId) {
  dict.foldl(tokens(value, policyId), 0, fn(_k, v, result) { v + result })
}

pub fn safe_list_at(list: List<a>, index: Int) {
  safe_expect(list.at(list, index))
}

pub fn safe_expect(maybeElem: Option<a>) {
  expect Some(elem) = maybeElem
  elem
}

pub fn value_to_pairs(value: Value) -> Pairs<PolicyId, Pairs<AssetName, Int>> {
  //This gives us Dict<PolicyId, Dict<ByteArray, Int>>
  let valueAsDict = to_dict(value)
  //This gives us Dict<PolicyId, Pairs<ByteArray, Int>>
  let dictOfPairs =
    dict.map(valueAsDict, fn(_k, innerDict) { dict.to_pairs(innerDict) })
  dict.to_pairs(dictOfPairs)
}

pub fn get_outputs_with_token(
  outputs: List<Output>,
  policyId: PolicyId,
  assetName: AssetName,
) -> List<Output> {
  list.filter(
    outputs,
    fn(output) { quantity_of(output.value, policyId, assetName) > 0 },
  )
}
