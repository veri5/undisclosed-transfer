import { ethers } from "ethers"
import { useEffect, useState } from 'react'
import evmContractABI from '../../contracts/abi/EvmContract.json'
import secretContractABI from '../../contracts/abi/SecretContract.json'
import styles from './Display.module.css'

const escrowContractAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3'
const evmContractAddress = '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0'
const secretContractAddress = '0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9'

export const Display = () => {
  const [provider, setProvider] = useState<ethers.JsonRpcProvider | undefined>();
  const [signer, setSigner] = useState<ethers.JsonRpcSigner | undefined>();
  const [recipient, setRecipient] = useState<ethers.JsonRpcSigner | undefined>();
  const [evmContract, setEvmContract] = useState<ethers.Contract | undefined>();
  const [secretContract, setSecretContract] = useState<ethers.Contract | undefined>();

  const [balance, setBalance] = useState<string | undefined>();
  const [recipientBalance, setRecipientBalance] = useState<string | undefined>();
  const [escrowBalance, setEscrowBalance] = useState<string | undefined>();
  const [secretBalance, setSecretBalance] = useState<string | undefined>();
  const [depositChanged, setDepositChanged] = useState<boolean>(false);

  useEffect(() => {
    const initializeContracts = async () => {
      if (window.ethereum) {
        try {
          const provider = new ethers.JsonRpcProvider('http://0.0.0.0:8545')
          setProvider(provider)

          const signer = await provider.getSigner("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266")
          setSigner(signer)

          const recipient = await provider.getSigner("0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc")
          setRecipient(recipient)

          const evmContract = new ethers.Contract(evmContractAddress, evmContractABI, signer)
          setEvmContract(evmContract)

          const secretContract = new ethers.Contract(secretContractAddress, secretContractABI, signer)
          setSecretContract(secretContract)

          const balanceWei = await provider.getBalance(signer.address)
          const balanceEth = ethers.formatEther(balanceWei)
          setBalance(balanceEth)

        } catch (error) {
          console.error('Error connecting to MetaMask:', error)
        }
      } else {
        console.error('MetaMask not detected. Please install and connect MetaMask.')
      }
    }
    initializeContracts()
  }, [])

  useEffect(() => {
    const fetchBalances = async (
      provider: ethers.JsonRpcProvider | undefined, 
      signer: ethers.JsonRpcSigner | undefined, 
      secretContract: ethers.Contract | undefined
    ) => {
      if (!provider || !signer || !recipient || !secretContract) {
        return
      }

      if (depositChanged) {
        try {
          const balanceWei = await provider.getBalance(signer.address)
          const balanceEth = ethers.formatEther(balanceWei)
          setBalance(balanceEth)

          const escrowBalanceWei = await provider.getBalance(escrowContractAddress)
          const escrowBalanceEth = ethers.formatEther(escrowBalanceWei)
          setEscrowBalance(escrowBalanceEth)

          const secretBalanceWei = await secretContract.balances(signer.address)
          const secretBalanceEth = ethers.formatEther(secretBalanceWei)
          setSecretBalance(secretBalanceEth)

          const recipientBalanceWei = await provider.getBalance(recipient.address)
          const recipientBalanceEth = ethers.formatEther(recipientBalanceWei)
          setRecipientBalance(recipientBalanceEth)

        } catch (error) {
          console.error('Error fetching balances:', error)
        }
        setDepositChanged(false)
      }
    }
    fetchBalances(provider, signer, secretContract)
  }, [provider, signer, secretContract, depositChanged])

  const handleDeposit = async (amount: string) => {
    if (!signer || !evmContract) return

    try {
      const parsedAmount = ethers.parseUnits(amount, 'ether')
      const transaction = await evmContract.deposit(signer.address, { value: parsedAmount })
      await transaction.wait()
      console.log('Deposit successful!')
      setDepositChanged(true)
    } catch (error) {
      console.error('Deposit failed:', error)
    }
  }

  const handleTransfer = async (amount: string) => {
    if (!signer || !recipient || !secretContract) return

    try {
      const parsedAmount = ethers.parseUnits(amount, 'ether')
      const transaction = await secretContract.transfer(signer.address, recipient.address, parsedAmount)
      await transaction.wait()
      console.log('Transfer successful!')
      setDepositChanged(true)
    } catch (error) {
      console.error('Transfer failed:', error)
    }
  }

  return (
    <div className={styles.display}>
      {/* {wallet.accounts.length > 0 && */}
      {signer && recipient &&
        <>
          <h3>Sender Wallet</h3>
          <div>Address: {signer.address}</div>
          <div>Balance: {balance}</div>
          <button onClick={(evt) => handleDeposit("16")}>Deposit</button>

          <h3>EVM Contract</h3>
          <div>Escrow Balance: {escrowBalance}</div>

          <h3>Secret Contract</h3>
          <div>Sender Balance: {secretBalance}</div>
          <button onClick={(evt) => handleTransfer("16")}>Transfer</button>
        
          <h3>Recipient Wallet</h3>
          <div>Address: {recipient.address}</div>
          <div>Balance: {recipientBalance}</div>
        </>
      }
    </div>
  )
}