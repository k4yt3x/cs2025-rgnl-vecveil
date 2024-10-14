# Lexicon & Vectors

To streamline the election process, Val Verde has implemented a digital check-in system allowing voters to pre-register online and receive a unique digital code, replacing traditional ID checks at polling stations. The system verifies the code upon arrival to ensure only registered voters can proceed to vote. Although these check-in machines are closely guarded, the Central Electoral Commission (CEC) wants to ensure that the system remains secure even if someone gains access to one of the machines.

As a hired security consultant, your task is to evaluate the system's security in two stages. In the first stage, you must analyze how the binary file "unpacks" its code, examining the packer used to protect the system. In the second stage, your challenge is to figure out how to forge a registration code, demonstrating how an attacker might exploit the system to gain unauthorized access. Your findings will be crucial in securing Val Verde's election.

## Stage 1: Unpacking the Code

In this stage, you are tasked with analyzing the binary which uses a special packing mechanism to obfuscate its own code. Your objective is to reverse-engineer its unpacking process and understand how it works.

Once you've figured out the packing mechanism, you will apply the same principles to unpack a standalone file provided to you. The unpacked file contains a flag in the format of `flag{}`. Your task is to retrieve and submit this flag to prove CEC's new packer is far too weak. The integrity of your nation rests in your hands!

## Stage 2: Forging a Registration Code

In this stage, your task is to analyze the binary further to uncover how the digital check-in system's authentication mechanism works. The system generates unique registration codes for each voter, and you must figure out how these codes are created.

You are required to forge a valid registration code for General Mateo Alvarez. Successfully generating this code will simulate bypassing the check-in process and impersonating the General. Val Verde's freedom depends on your success!
