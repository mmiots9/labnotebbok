<h1 align="center">Labnotebook 📔🖥</h1>

This project aims to help bioinformaticians in creating the so called "Laboratory notebook" automatically, thanks to git workflow manager.

**IMPORTANT**: this tool is based on git and its application. Based on git history, it will create an html notebook divided by date and commit.

<h3 style="margin-bottom:3px;">Features</h3>
<ul>
  <li>Automatically create a laboratory notebook</li>
  <li>Customizable CSS file</li>
  <li>Possibility to ignore the labnotebook folder in commits</li>
  <li>Possibility to ask for analysis file link in the notebook</li>
  <li>Export to html</li>
</ul>

<h3>Installation</h3>
To install these functions, I strongly recommend to download the entire folder and add this to your .bash_profile or .zshrc:

```
for file in ~/path-to-folder/*.sh; do source "$file"; done
```
<h3>Notebook structure</h3>
The structure of the notebook is very simple. You can see an example <a href='https://miotsdata.netlify.app/it/bash/mie_funzioni/example.html' target='_blank'>here</a>.

<p style="margin-bottom:0px;">On top, you have the notebook name, the author and the notebook creation date. Then, for each day, you have a list of all the commits done, organized as follow:</p>
<ul>
  <li>Commit message (first line)</li>
  <li>Commit body</li>
  <li>sha</li>
  <li>Analysis file (if set)</li>
  <li>List of changed files</li>
</ul>

<h3>Create a notebook</h3>
To create a notebook, go to the folder in which is present the .git folder and type <code>createnotebook \<name_of_the_notebook\></code>.  
A .labnotebook folder is created, containing config file, a basic css file and three file containing head, body and footer of the html file.

**IMPORTANT**: never change the name of the created folder and its files. 

<h3>Update a notebook</h3>
When you want to update the notebook, go to the folder in which is present the .git folder, type <code>updatenotebook</code> and follow the instructions.

**IMPORTANT**: If you have set to NOT ignore .labnotebook folder, after each notebook update a commit is made with labnotebook as author.

<h3>Export html file</h3>
When you want to export the full html file containing the notebook, go to the folder in which is present the .git folder, type <code>exportnotebook \<file_to_create.html\></code>
