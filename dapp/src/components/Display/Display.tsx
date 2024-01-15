import { useMetaMask } from '~/hooks/useMetaMask'
import styles from './Display.module.css'

export const Display = () => {

  const { wallet } = useMetaMask()

  const deposit = () => {}

  const transfer = () => {}

  return (
    <div className={styles.display}>
      {wallet.accounts.length > 0 &&
        <>
          <h3>Sender Wallet</h3>
          <div>Address: {wallet.accounts[0]}</div>
          <div>Balance: {wallet.balance}</div>
          <button onClick={deposit}>
            Deposit
          </button>

          <h3>EVM Contract</h3>
          <div>Sender Balance: {0}</div>

          <h3>Secret Contract</h3>
          <div>Sender Balance: {0}</div>
          <div>
            <label>Amount:
              <input type="number" id="quantity" min="0.1" max={wallet.balance} defaultValue={0} />
            </label>
          </div>
          <div>
            <label>Recipient:
              <input id="recipient" defaultValue={wallet.accounts[1]} />
            </label>  
          </div>
          
          <button onClick={transfer}>
            Transfer
          </button>
          
          <h3>Recipient Wallet</h3>
          <div>Address: {wallet.accounts[1]}</div>
          <div>Balance: {0}</div>
        </>
      }
    </div>
  )
}