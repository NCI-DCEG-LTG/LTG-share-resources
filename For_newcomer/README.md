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

- **For CCAD2 and T/L-Drive access and setup, please contact:**

  ```
  Nathan Cole: nathan.cole@nih.gov
  or
  Eamonn O'Neil: eamonn.o'neil@nih.gov
  ```

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
| **Local Machine** | Light tasks, writing scripts, testing code, small analyses | Set up via NCI IT |

#### Quick Tips
- **Biowulf** is the go-to for computationally intensive work. Jobs are submitted via SLURM. See the [Biowulf user guide](https://hpc.nih.gov/docs/userguide.html) to get started.
- **Do not run heavy jobs on the login node** on Biowulf — always submit via `sbatch` or use an interactive session (`sinteractive`).
- For **storage**, keep large datasets on Biowulf `/data` or the L/T-Drive rather than your local machine.
- When in doubt about which system to use, ask your PI or contact Nathan Cole.

---

### Points of Contact

- The file `xxx` contains a list of people who can be contacted for specific questions.
