## Useful Information for Newcomers

### Our LTG Main Page and PI Information

- **Principal Investigators (PIs)**
  - [Ludmila Prokunina-Olsson](https://dceg.cancer.gov/about/organization/tdrp/ltg/prokunina-olsson-laboratory)
  - [Michael Dean](https://dceg.cancer.gov/about/organization/tdrp/ltg/michael-dean-lab)
  - [Laufey Amundadottir](https://dceg.cancer.gov/about/organization/tdrp/ltg/amundadottir-lab)
  - [Kevin Brown](https://dceg.cancer.gov/about/organization/tdrp/ltg/brown-lab)
  - [Jiyeon Choi](https://dceg.cancer.gov/about/organization/tdrp/ltg/choi-lab)

---

### Things to Set Up and Where to Find Help

- **[NCI IT Help Website](https://service.cancer.gov/ncisp?id=nci_home)**
  All kinds of IT support, such as setting up a printer, installing software and licenses, etc.

- **Biowulf (NIH HPC) Account Setup:** https://hpc.nih.gov/docs/accounts.html

- **For CCAD and T/L-Drive access and setup, please contact:**

  ```
  Nathan Cole: nathan.cole@nih.gov
  Eamonn O'Neil: eamonn.o'neil@nih.gov
  ```

- **[CCAD User Notes](https://nih.sharepoint.com/sites/NCI-DCEG-CGRIT/SitePages/CGR-IT-Cluster_CCAD3.aspx?xsdata=MDV8MDJ8fDc2NTNiZGEzN2ZlYzRjZGU1ZjcwMDhkZTdhMGE4MTY5fDE0Yjc3NTc4OTc3MzQyZDU4NTA3MjUxY2EyZGMyYjA2fDB8MHw2MzkwODIzODI2NzI2MTczMjh8VW5rbm93bnxWR1ZoYlhOVFpXTjFjbWwwZVZObGNuWnBZMlY4ZXlKRFFTSTZJbFJsWVcxelgwRlVVRk5sY25acFkyVmZVMUJQVEU5R0lpd2lWaUk2SWpBdU1DNHdNREF3SWl3aVVDSTZJbGRwYmpNeUlpd2lRVTRpT2lKUGRHaGxjaUlzSWxkVUlqb3hNWDA9fDF8TDJOb1lYUnpMekU1T2pNd05EUmpPV1F6WmpGbU1UUXhaVE00TURSaU5HVXdORFkwTXpBd01XTTJRSFJvY21WaFpDNTJNaTl0WlhOellXZGxjeTh4TnpjeU5qUXhORFF4TkRBeHwxNTlmZjUwYWIyM2Y0NzBlNWY3MDA4ZGU3YTBhODE2OXw0NWI1ODg1YjJiMmE0ZmQ0YjI5MjE4OTAyMjJjNDlkNA%3D%3D&sdata=K3JXTU5ISnBkYk5pODlwZmRCN2UrY2pja0FEOThRbHF3MHVMOUdwa005ST0%3D&ovuser=14b77578-9773-42d5-8507-251ca2dc2b06%2Cleec20%40nih.gov&OR=Teams-HL&CT=1773860089434&clickparams=eyJBcHBOYW1lIjoiVGVhbXMtRGVza3RvcCIsIkFwcFZlcnNpb24iOiI1MC8yNjAyMTIxNTEyMyJ9)** contians a list of useful tutorial for new ccad user


---

### LTG Handbook Location

- The LTG Handbook contains relevant information about CRL, NIH onboarding, trainee and fellow resources, and centralized lab information.
- The PDF is located on the L-Drive at: `LTG/LTG Handbook/LTG Handbook April 2022.pdf`
  - This folder also contains additional useful resources.

---

### Computing Resources Overview

| System | Best Used For | Access |
|--------|--------------|--------|
| **Biowulf** | Large-scale HPC jobs, parallel computing, genomics pipelines (e.g., GATK, PLINK), long-running batch jobs | [Request account](https://hpc.nih.gov/docs/accounts.html) |
| **CCAD2** | NCI-specific computing, lab-shared workflows | Contact Nathan Cole or Eamonn O'Neil (see above) |
| **L-Drive / T-Drive** | Shared lab file storage, documents, reference data | Contact Nathan Cole or Eamonn O'Neil (see above) |
| **Government Laptop** | Light tasks, writing scripts, testing code, small analyses | Issued and set up by NCI IT  |

#### Quick Tips
- **Biowulf** is the go-to for computationally intensive work. Jobs are submitted via SLURM. See the [Biowulf user guide](https://hpc.nih.gov/docs/userguide.html) to get started.
- **Do not run heavy jobs on the login node** on Biowulf — always submit via `sbatch` or use an interactive session (`sinteractive`).
- When in doubt about which system to use, ask your PI or contact related staff.

---

### Points of Contact

- The file `xxx` contains a list of people who can be contacted for specific questions.
