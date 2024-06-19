use aiken/list.{length}
use aiken/transaction.{InlineDatum, Input, Output, ScriptContext, Spend}
use aiken/transaction/value.{flatten, quantity_of}
use types.{AcceptedLessonDatum, LessonRequestDatum}
use utils.{
  get_outputs_with_token, get_own_hash, is_before, is_output_to_sc,
  is_policyId_present, must_be_signed_by,
}

type Redeemer {
  Transfer {
    //index in the reference input list
    ownerNFTIndex: Int,
    //indexes in the reference input list, one for each output that receives tokens
    receiversNFTIndex: List<Int>,
  }
}

validator(
  securityScriptHash: ByteArray,
  securityPolicyId: PolicyId,
  securityAssetName: AssetName,
  allowanceNFTPolicyId: PolicyId,
  owner: Address,
) {
  fn spend(
    datum: LessonRequestDatum,
    redeemer: Redeemer,
    ctx: ScriptContext,
  ) -> Bool {
    // we need the contract hash
    let ownScriptHash = get_own_hash(ctx.purpose, ctx.transaction.inputs)

    when ctx.purpose is {
      Spend(currentInput) ->
        when redeemer is {
          Transfer(ownerNFTIndex, receiversNFTIndex) -> and {
              is_user_allowed(
                ctx.transaction.reference_inputs,
                ownerNFTIndex,
                owner,
                allowanceNFTPolicyId,
              ),
              validate_all_outputs(
                ctx.transaction.reference_inputs,
                ctx.transaction.outputs,
                securityPolicyId,
                securityAssetName,
                receiversNFTIndex,
                ownScriptHash,
                allowanceNFTPolicyId,
              ),
            }
        }
    }
  }
}

//TODO THIS COULD BE MADE ONCE FOR ALL INPUTS USING WITHDRAW 0
fn is_user_allowed(
  referenceInputs: List<Input>,
  referenceInputNFTIndex: Int,
  stake_credential: Option<StakeCredential>,
  allowanceNFTPolicyId: PolicyId,
) {
  expect Some(userRefInput) =
    list.at(tx.reference_inputs, referenceInputNFTIndex)
  and {
    userRefInput.stake_credentials == stake_credential,
    is_policyId_present(userRefInput.output, allowanceNFTPolicyId),
  }
}

//TODO THIS COULD BE MADE ONCE FOR ALL OUTPUTS USING WITHDRAW 0
fn validate_all_outputs(
  referenceInputs: List<Input>,
  outputs: List<Output>,
  securityPolicyId: PolicyId,
  securityAssetName: AssetName,
  receiversNFTIndex: List<Int>,
  ownScriptHash: ByteArray,
  allowanceNFTPolicyId: PolicyId,
) {
  let outputsWithThisToken =
    get_outputs_with_token(outputs, securityPolicyId, securityAssetName)

  let outputsAndRefInputIndexes =
    list.zip(outputsWithThisToken, receiversNFTIndex)

  list.all(
    outputsAndRefInputIndexes,
    fn(outputAndRefIndex) {
      let output = outputAndRefIndex.first
      and {
        is_output_to_sc(output, ownScriptHash),
        is_user_allowed(
          referenceInputs,
          outputAndRefIndex.2nd,
          output.address.stake_credential,
          allowanceNFTPolicyId,
        ),
        //dos protection
        length(flatten(output.value)) <= 5,
      }
    },
  )
}
