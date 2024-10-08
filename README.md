# Bafin compliant securities

This set of smart contracts allow to have Bafin compliant security tokens on Cardano.
It follows the latest version of CIP-113 made by Michele Nuzzi and Matteo Coppola:
https://github.com/HarmonicLabs/CIPs/tree/master/CIP-meta-assets%20(ERC20-like%20assets)

Bafin requires the user's security tokens to be freezable and to lock them eventually when the user requests to remove his ownership.

## Actors

The flow implies the need of the following actors:
* Bafin: declared as an Address
* Issuer: approved by Bafin, the issuer of a certain security token
* Admin: approved by a issuer, admins the users and security tokens for one security
* User: CIP-113 compliant users with a state and any number of utxos containing security tokens

## How it works

* Bafin Address can create a new issuer minting an NFT, specifying issuer's stakeCredentials and locking in issuer_manager.
* Bafin Address then can create a SecurityInfo minting an NFT, specifying issuer's stakeCredentials and locking in security_info.
* A issuer can then create a new admin minting an NFT, specifying admin's stakeCredentials and locking in admin_manager.
* A admin can then create a user state minting an NFT, specifying user's stakeCredentials and locking in a dedicated state_manager instance.
* A issuer can then create securities minting them in a dedicated transfer_manager instance.
* Bafin can remove an issuer changing stakeCredentials of his issuer utxo.
* A issuer can edit the security infos for the security_info utxos he controls.
* A issuer can remove an admin changing stakeCredentials of his admin utxo.
* An admin can freeze a user changing stakeCredentials of his state utxo.
* An admin can lock user's securities sending them in a utxo to locked_transfer_manager. 
* An admin can lock user's securities and give them to anyone sending them in a utxo to transfer_manager. 

For each security, there's 1 issuer utxo, 1 security_info utxo, 1 admin utxo, 1 state_manager SC instance and 1 transfer_manager SC instance.
Only 1 locked_transfer_manager SC exists for all the securities, the utxo datum specifies where the securities are coming from.

Following CIP-113, the security tokens can move only inside the transfer_manager and the locked_transfer_manager SCs.

To check if a issuer or an admin is enabled and legit, there must be a utxo in the proper SC with the proper NFT and with the user stakeCredentials.
To check if a user is enabled and legit, there must be a utxo in the state_manager SC with a NFT and the user's stakeCredentials in the datum.
To invalidate a issuer, an admin or a user, you just need to spend his utxo and remove his stakeCredentials.

## Authors

Matteo Coppola, as part of Finest team