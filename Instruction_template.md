# Instructions



---

##### Cloning the repository

```
git clone "repository"
# The "repository" can be copied from the repository website
# Copy the link under the "Clone or Download" button
# This version is the SSH version there is also an HTTPS version
git clone git@github.com:tgen/Institutional_Instructions.git
```

#####  pull down the most recent version
```
git pull
# Likely get the following message the first time, before modifying you should "pull" to get most recent code
Already up-to-date.
```

##### MODIFY THE FILES YOU NEED TO MODIFY

###### IF YOU CREATED NEW FILES YOU WILL NEED TO "ADD" THEM BEFORE COMMITTING AND PUSHING
```
git add Message.sh
    
git add file OR git add folder
#Add gender test folder
git add gender_test/
#Add all files in gender test folder
git add gender_test/*
```

##### Commit the changes AND add a comment
```
git commit -am "your comment about what you changed"
git commit -am "Added message file for example ADD, COMMIT, and PUSH"
```
##### Then to push the update to the github website
```
git push #this pushes your changes to github
git push
```

---

# Markdown Cheatsheet

# Headers Code:
```
# Header 1
## Header 2
### Header 3
#### Header 4
##### Header 5
###### Header 6
```
### Headers Code Example:
# Header 1
## Header 2
### Header 3
#### Header 4
##### Header 5
###### Header 6

# Separator Code:
```
Text Above
---
Three or more dashes/hyphens, creates thin line
****
Three or more astericks, creates thick line
_____
Three or more underscores, creates thicker line?
```
### Separator Code Example:  

Text Above
---
Three or more dashes/hyphens, creates thin line
****
Three or more astericks, creates thick line
_____
Three or more underscores, creates thicker line?

# Emphasis Code:
```
NOTE: Each line, except last, ends with two spaces "  " to prevent wrapping  
Bold - **Bold** or __Bold__ (double asterisks or underscores)  
Italics - *Italics* or _Italics_ (single asterisks or underscores)  
Strikethrough - ~~Strikethrough~~ (double tildes)
```
### Emphasis Code Example:
NOTE: Each line, except last, ends with two spaces "  " to prevent wrapping  
Bold - **Bold** or __Bold__ (double asterisks or underscores)  
Italics - *Italics* or _Italics_ (single asterisks or underscores)  
Strikethrough - ~~Strikethrough~~ (double tildes)

# List Code:
```
1. Keats Lab (Ordered Sub-list)
  1. Wet Lab (Two indent spaces)
    1. Martin (Four indent spaces)
    2. Brooks
  2. Informatics (Ordered sub-list with letters)
    1. Austin
    2. Christophe
    3. Megan
    4. Jessica
    5. Sara
2. Liang Lab (Unordered sub-list, can use "*", "-", or "+")
  * Winnie
  - Lori
  + Jonathan
```
### List Code Example:
1. Keats Lab (Ordered Sub-list)
  1. Wet Lab (Two indent spaces)
    1. Martin (Four indent spaces)
    2. Brooks
  2. Informatics (Ordered sub-list with letters)
    1. Austin
    2. Christophe
    3. Megan
    4. Jessica
    5. Sara
2. Liang Lab (Unordered sub-list, can use "*", "-", or "+")
  * Winnie
  - Lori
  + Jonathan

# Table Code:

**Note**: Tables columns are defined by pipes (|), the header row is
defined by inserting at least 3 hyphens (---) on the line below. You
can set the alignment of each column using colons (:) on the header
defining row, left (:---), center (:---:), right (---:).  You can align
things with spaces but it will occur automatically in the simple version
below

```
Gene | Chromosome | Cancer Gene | Note
:--- | :---: | ---: | ---
TRAF3 | 14 | Yes | col1 left aligned
WHSC1L1 | 8 | No | col2 centered
RB1 | 13 | Yes | col3 right aligned
```
### Table Code Example:
Gene | Chromosome | Cancer Gene | Note
:--- | :---: | ---: | ---
TRAF3 | 14 | Yes | col1 left aligned
WHSC1L1 | 8 | No | col2 centered
RB1 | 13 | Yes | col3 right aligned

# Code Block Code:

**Note**: Code blocks can be indicated by either 4 spaces ("    ") or above
and below wrapped with three back ticks (```). The advantage of back
ticks is it allows the definition of the code type so language specific
syntax coloring can occur. In the example below the set of code blocks
are indented with four spaces and then the back ticks used in the example
are shown.

    ```python
    s = "Python syntax highlighting"
    print(s)
    ```
    
    ```bash
    i="Bash syntax highlighting"
    echo ${i}
    exit 1
    ```
    
    ```javascript
    var s = "JavaScript syntax highlighting";
    alert(s);
    ```
    
    ```
    No language indicated, so no syntax highlighting. 
    But let's throw in a <b>tag</b>.
    ```
    
# Code Block Example:
```python
s = "Python syntax highlighting"
print(s)
```

```bash
i="Bash syntax highlighting"
echo ${i}
exit 1
```

```javascript
var s = "JavaScript syntax highlighting";
alert(s);
```

```
No language indicated, so no syntax highlighting. 
But let's throw in a <b>tag</b>.
```
