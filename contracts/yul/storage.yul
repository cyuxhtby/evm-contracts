object "Storage" {
    // this section is for deploying the contract, it prepares the runtime code
    code {
        // copy the runtime code into memory starting at position 0
        // `dataoffset("Runtime")` gets the start position of the "Runtime" object's code
        // `datasize("Runtime")` gets the size of the "Runtime" object's code
        datacopy(0, dataoffset("Runtime"), datasize("Runtime"))
        // return the runtime code to be deployed
        // this makes the "Runtime" part of the code the actual contract code
        return(0, datasize("Runtime"))
    }
    object "Runtime" {
        // code that will be executed once the contract is deployed
        code {
            // entry point for calls to the contract
            // `calldataload(0)` loads the first 32 bytes of call data into memory, which is used for selecting the function
            switch calldataload(0)
            // store value
            case 0 {
                // `calldataload(0x04)` skips the first 4 bytes (function selector) and loads the next 32 bytes (value to store)
                let value := calldataload(0x04)
                // store the value at storage position 0
                sstore(0, value)
            }
            // retreive value
            case 1 {
                // load the value stored at storage position 0
                let value := sload(0)
                // Store the loaded value at memory position 0
                mstore(0, value)
                // `0x20` is 32 in decimal 
                // Ethereum's word size is 32 bytes, and we are returning a single word
                return(0, 0x20)
            }
        }
    }
}
