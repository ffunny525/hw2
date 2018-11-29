const fs = require('fs')
const Web3 = require('web3')

let web3 = new Web3('http://localhost:8545')

const abi = JSON.parse(fs.readFileSync('./contract/Bank_sol_Bank.abi').toString())
const bytecode = '0x' + fs.readFileSync('./contract/Bank_sol_Bank.bin').toString()

let bank = new web3.eth.Contract(abi)

web3.eth.getAccounts().then(function (accounts) {
    bank.options.data = bytecode;
    bank
    .deploy({
      arguments: []
    })
    .send({
      from: accounts[0],
      gas: 1500000,
      gasPrice: "10"
    }).then(result => {
        fs.writeFileSync('./address.txt', result.options.address)
    })
})
