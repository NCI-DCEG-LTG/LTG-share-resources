# GEO Submission Guide

## Goal
Assisting with GEO submission

## Choosing Between SRA and GEO

**Which submission portal should I use?**

- **SRA submission**: Submit only FASTQ files
- **GEO submission**: Submit FASTQ files AND processed data (gene raw counts, single-cell gene/barcode/matrix counts, etc.)

## Submission Workflow

### STEP 1: Download and Fill Metadata Tables

The GEO website provides clear instructions:
- **Main page**: https://www.ncbi.nlm.nih.gov/geo/info/seq.html
- **Metadata template**: https://www.ncbi.nlm.nih.gov/geo/info/seq.html#metadata

**Required sheets to complete:**
1. **Sheet 2: Metadata Template**
2. **Sheet 3: MD5 Checksums**

**Accepted file types:**
- **Raw data files**: FASTQ files (can be gzipped)
- **Processed files**: Single-cell RDS files, BigWig files, TPM/FPKM tables, etc.

**Generate MD5 checksums:**

On Biowulf, use the following command:
```bash
md5sum <yourfile> > output.txt
```
The output file will contain the filename with its MD5 checksum.

---

### STEP 2: Request FTP Upload Space

1. **Log in to GEO** and create a new submission

2. **Request FTP space**
   - After requesting the FTP folder, refresh the webpage after a few seconds
   - The page will generate new sections with upload instructions

3. **Locate your FTP credentials:**
   - FTP server address
   - Upload directory path
   - **Password**: Found in the expanded section titled **"Step 2. Transfer all your raw and processed data files to your personalized upload space according to FTP upload instructions below. Do not upload the metadata file by FTP."**
     - Click to expand this section
     - The password is shown below the username
     - **Save this password** - you'll need it for file transfer

---

### STEP 3: Upload Files to GEO FTP

You can upload files using **FileZilla** or **Biowulf's Helix system** (recommended if you have a Biowulf account).

#### Upload via Biowulf Helix System

**Reference**: https://hpc.nih.gov/docs/transfer.html#GEO

**Instructions:**

1. **SSH to Helix** using your Biowulf credentials:
   ```bash
   ssh helix.nih.gov
   ```

2. **Create a tmux session** to prevent disconnection:
   ```bash
   # -s: create your project name
   tmux new -s myproject
   ```

3. **Access the GEO FTP site**:
   ```bash
   lftp ftp://geoftp@ftp-private.ncbi.nlm.nih.gov
   ```
   - When prompted, enter the password from Step 2.3

4. **Navigate to your upload directory**:
   ```bash
   cd uploads/user@nih.gov_xxxxx
   ```

5. **Create a submission folder**:
   ```bash
   mkdir for_submission
   cd for_submission
   ```

6. **Upload files**:

   **Option A: Upload entire folder** (fastest method):
   ```bash
   # Mirror a complete directory from local to FTP
   # Example: uploading a folder containing FASTQ files
   mirror -R /data/Choi_lung/ChiaHan/GEO_upload_Bolun_11252025/fastqs_dir
   ```

   **Option B: Upload specific files**:
   ```bash
   # Upload single file
   put sample.fq.gz
   
   # Upload multiple files
   mput *.fq.gz
   ```

7. **Verify upload**:
   ```bash
   ls for_submission
   ```

8. **Exit lftp**:
   ```bash
   exit
   ```

**Alternative: Using scp directly** (outside lftp):
```bash
# Upload single file
scp sample.fq.gz geoftp@sftp-private.ncbi.nlm.nih.gov:uploads/user@nih.gov_xxxxx

# Upload entire folder
scp -r submission_dir geoftp@sftp-private.ncbi.nlm.nih.gov:uploads/user@nih.gov_xxxxx
```

---

### STEP 4: Upload Metadata File

1. **Go to**: https://submit.ncbi.nlm.nih.gov/geo/submission/meta/

2. **Select your data type**

3. **Select upload subfolder**:
   - Choose the parent folder containing your raw and processed data
   - In this example, select `for_submission`

4. **Upload the metadata Excel file**
   - The system will validate the file and check for errors
   - Review and fix any errors reported

---

### STEP 5: Submit and Wait for GEO Response

Once all files are uploaded and metadata is validated, submit your GEO entry. GEO curators will review your submission and contact you with any questions or to confirm acceptance.

---

## Quick Reference Commands

**Check tmux sessions** (to resume interrupted uploads):
```bash
# List all tmux sessions
tmux ls

# Reattach to your session
tmux attach -t myproject
```

**Check upload progress**:
```bash
# Inside lftp, monitor transfer
jobs

# Check available space
du -sh *
```
