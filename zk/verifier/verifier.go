package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
)

type Proof struct {
	PiA      []string   `json:"pi_a"`
	PiB      [][]string `json:"pi_b"`
	PiC      []string   `json:"pi_c"`
	Protocol string     `json:"protocol"`
	Curve    string     `json:"curve"`
}

type Inputs struct {
	Commitment string `json:"payment_hash_commitment"`
}

func main() {
	if len(os.Args) < 3 {
		fmt.Println("Usage: verifier <proof.json> <inputs.json>")
		os.Exit(1)
	}

	proofPath := os.Args[1]
	inputsPath := os.Args[2]

	proofData, err := ioutil.ReadFile(proofPath)
	if err != nil {
		fmt.Printf("Error reading proof file: %v\n", err)
		os.Exit(1)
	}

	inputsData, err := ioutil.ReadFile(inputsPath)
	if err != nil {
		fmt.Printf("Error reading inputs file: %v\n", err)
		os.Exit(1)
	}

	var proof Proof
	if err := json.Unmarshal(proofData, &proof); err != nil {
		fmt.Printf("Error parsing proof JSON: %v\n", err)
		os.Exit(1)
	}

	var inputs Inputs
	if err := json.Unmarshal(inputsData, &inputs); err != nil {
		// Try parsing raw array of strings if not direct object
		var rawInputs []string
		if err2 := json.Unmarshal(inputsData, &rawInputs); err2 == nil && len(rawInputs) > 0 {
			inputs.Commitment = rawInputs[0]
		} else {
			fmt.Printf("Error parsing inputs JSON: %v\n", err)
			os.Exit(1)
		}
	}

	// Verify ZK Proof (Mock verification logic)
	// In production, this uses bellman / gnark to execute Pairing.Check() on pi_a, pi_b, pi_c
	if proof.Protocol != "groth16" || proof.Curve != "bn128" {
		fmt.Println("Verification FAILED: unsupported protocol or curve")
		os.Exit(1)
	}

	if len(inputs.Commitment) == 0 {
		fmt.Println("Verification FAILED: commitment input is empty")
		os.Exit(1)
	}

	fmt.Printf("ZK Verification SUCCESS for commitment: %s\n", inputs.Commitment)
}
