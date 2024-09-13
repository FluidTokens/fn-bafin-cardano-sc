use aiken/collection/list.{foldl, length}
use cardano/address.{Address, Credential, Script}
use cardano/assets.{AssetName, flatten, quantity_of}
use cardano/transaction.{Input, Output, OutputReference, Transaction}
use types.{
  LockedTransferManagerSpendRedeemer, LockedTransferManagerWithdrawRedeemer,
}
use utils.{
  get_inputs_from_sc, get_outputs_to_sc, get_own_hash, must_be_signed_by,
}

validator locked_transfer_manager(custodialAdminAddress: Address) {
  spend(
    _datumOpt: Option<Data>,
    redeemer: LockedTransferManagerSpendRedeemer,
    input: OutputReference,
    self: Transaction,
  ) {
    let ownScriptHash = get_own_hash(input, self.inputs)
    expect Some(withdrawScript) =
      list.at(self.withdrawals, redeemer.withdrawIndex)
    when withdrawScript is {
      Pair(Script(scriptHash), _amnt) -> scriptHash == ownScriptHash
      _ -> False
    }
  }

  withdraw(
    redeemer: LockedTransferManagerWithdrawRedeemer,
    credential: Credential,
    self: Transaction,
  ) {
    expect Script(ownScriptHash) = credential
    and {
      must_be_signed_by(self, custodialAdminAddress),
      areAllInputTokensToTransferManager(
        self.inputs,
        self.outputs,
        ownScriptHash,
      ),
    }
  }

  else(_) {
    fail
  }
}

fn areAllInputTokensToTransferManager(
  inputs: List<Input>,
  outputs: List<Output>,
  ownScriptHash: ByteArray,
  tranferManagerScriptHash: ByteArray,
  securityAssetName: AssetName,
) {
  let inputsFromThisSC = get_inputs_from_sc(inputs, ownScriptHash)
  let outputsToTransferManager =
    get_outputs_to_sc(outputs, tranferManagerScriptHash)
  let tokensAmountFromThisSC =
    foldl(
      inputsFromThisSC,
      0,
      fn(input, result) {
        let inputSecurityAmount =
          quantity_of(
            input.output.value,
            tranferManagerScriptHash,
            securityAssetName,
          )
        //All inputs must have the security token
        expect inputSecurityAmount > 0
        inputSecurityAmount + result
      },
    )
  let tokensAmountToTransferManager =
    foldl(
      outputsToTransferManager,
      0,
      fn(output, result) {
        let outputSecurityAmount =
          quantity_of(output.value, tranferManagerScriptHash, securityAssetName)

        //Dos protection
        expect length(flatten(output.value)) <= 5
        //All inputs must have the security token
        expect outputSecurityAmount > 0
        outputSecurityAmount + result
      },
    )

  tokensAmountFromThisSC == tokensAmountToTransferManager
}
