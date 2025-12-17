#### Goal: Get DNA sequence from list of bed file using UCSC genome brower. 
Our goal is to extract DNA sequences for regions specified in a BED file using the UCSC Genome Browser. 

The BED file lists each interval by chromosome, start, and end coordinates, and we use the browser’s sequence retrieval tools to download the matching FASTA entries.

#### Code/protocol:

1.  Prepare your BED file: Ensure your BED file is properly formatted with chromosome, start, and end coordinates. 
2. Upload the BED file as a custom track: Navigate to the UCSC Genome Browser's Add Custom Tracks page and upload your BED file. 
3. Access the Table Browser: Go to the Table Browser from the Genome Browser's interface. 
4. Select your custom track: In the Table Browser, select the custom track you just uploaded. 
5. Choose sequence output format: In the Table Browser, choose "sequence" as the output format. You can also choose other formats like FASTA. 
