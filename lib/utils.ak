use aiken/interval.{Finite, Interval}
use aiken/list.{length}
use aiken/time.{PosixTime}
use aiken/transaction.{Input, Output, ScriptPurpose, Spend, Transaction}
use aiken/transaction/credential.{
  Address, ScriptCredential, VerificationKeyCredential,
}

pub fn is_before(txValidityRange: Interval<PosixTime>, time: Int) {
  when txValidityRange.upper_bound.bound_type is {
    Finite(end) -> end < time
    _ -> fail
  }
}

pub fn is_after(txValidityRange: Interval<PosixTime>, time: Int) {
  when txValidityRange.lower_bound.bound_type is {
    Finite(start) -> start > time
    _ -> fail
  }
}

pub fn must_be_signed_by(transaction: Transaction, address: Address) {
  expect VerificationKeyCredential(hash) = address.payment_credential
  list.has(transaction.extra_signatories, hash)
}

pub fn get_own_hash(purpose: ScriptPurpose, txInputs: List<Input>) {
  expect Spend(output_reference) = purpose

  let inputList =
    list.filter(txInputs, fn(x) { x.output_reference == output_reference })

  expect Some(input) = list.head(inputList)
  when input.output.address.payment_credential is {
    ScriptCredential(hash) -> hash
    _ -> fail
  }
}

pub fn is_output_to_sc(output: Output, scHash: ByteArray) -> Bool {
  when output.address.payment_credential is {
    ScriptCredential(hash) -> hash == scHash
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
    ScriptCredential(_) -> True
    _ -> False
  }
}

pub fn only_one_input_from_sc(inputs: List<Input>) {
  let inputsWithDatum =
    list.filter(inputs, fn(input) { is_script_output(input.output) })
  length(inputsWithDatum) == 1
}
