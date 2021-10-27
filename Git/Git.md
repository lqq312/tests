[TOC]

# Git简介

自诞生于2005年以来，Git日臻成熟完善，它的速度快，极其适合管理大型项目，它还有着令人难以置信的非线性分支管理系统，可以应付各种复杂的项目开发需求。



Git、GitHub与GitLab的区别：

* Git是一个版本控制软件；
* GitHub与GitLab都是用于管理版本的服务端软件；
* GitHub提供免费服务（代码需要公开）及付费服务（代码私有）；
* GitLab用于在企业内部管理Git版本库，功能上类似于GitHub。



Git的优势：

* 本地建立版本库；
* 本地版本控制；
* 多主机异地协同工作；
* 重写提交说明；
* 所有的操作均可撤销；
* 有好用的提交列表；
* 更好的差异比较；
* 有更完善的分支系统；
* 速度极快。



Git的工作模式：

![git工作模式01](/Users/luqq/Documents/02_tec-doc/Git/pics/git工作模式01.jpg)

* 版本库初始化，个人计算机从版本服务器同步；
* 添加文件、修改文件、提交变更、查看版本历史等均可在个人计算机上进行；
* 将已完成的修改推送至版本服务器。



Git文件存储：

![Git文件存储01](/Users/luqq/Documents/02_tec-doc/Git/pics/Git文件存储01.png)

传统的版本控制系统维护的是每个文件增量的变化，而Git维护的是全量的变化。



## Git版本库状态变化

Git的文件状态：

* 直接记录快照，而非差异比较；
* 近乎所有操作都在本地执行；
* 时刻保持数据完整性；
* 多数操作仅添加数据；
* Git中的文件的三种状态：已修改（modified）、已暂存（staged，也可称为index）和已提交（committed）。



Git文件状态详解：

![Git文件状态01](/Users/luqq/Documents/02_tec-doc/Git/pics/Git文件状态01.png)

* Git文件：已被版本库管理的文件；
* 已修改：在工作目录修改的Git文件；
* 已暂存：对已修改的文件执行Git暂存操作，将文件存入暂存区；
* 已提交：将已暂存的文件执行Git提交操作，将文件存入版本库。



![Git文件状态02](/Users/luqq/Documents/02_tec-doc/Git/pics/Git文件状态03.jpeg)

git add：将工作区的文件加入至版本库（即暂存区）；

git commit：将暂存区的文件加入至本地版本库中，该文件才会被版本控制系统管理，“commit id”是一个摘要值，其值是使用“SHA1”计算而来的。

git rm：回到版本库的上一个状态；

git checkout：从暂存区或版本库中拉出指定文件至工作区，该命令会将工作区内的文件覆盖如误操作则无法回退；

git status：查看本地版本库的状态信息，可查看是否有文件已修改尚未提交或存在尚未追踪的文件。

git config：配置本地基础信息，以便Git记录每次提交的用户及对应的邮箱。



本地版本库与服务器版本库之间的关系：

![版本库关系01](/Users/luqq/Documents/02_tec-doc/Git/pics/版本库关系01.png)



## 配置本地个人信息

使用“git config”命令可显式的配置基础信息。本地的配置可在三个文件中配置，其作用范围从大到小：

 	1. /etc/gitconfig，全局生效，对该计算机上的所有用户均首先读取该文件中的内容；
     * git config --system
 	2. ~/.gitconfig，仅对当前用户生效；
     * git config --global
 	3. .git/config，仅对当前项目生效。
     * git config --local

以上文件的读取顺序：/etc/gitconfig ==> ~/.gitconfig ==> .git/config，如多个文件中对同一参数有多个值，则后面的值会覆盖前面的值。



.gitignore：将不需要被“git”管理的文件写在这个文件中，该文件的内容用于匹配项目目录下的文件，支持正则表达式，被匹配到的文件则不会被“git”所管理；该文件必须在项目的根目录下。

 	1. *.a：忽略所有以“.a”结尾的文件；
 	2. !lib.a：从以上的规则中排除lib.a；
 	3. /FILE：仅忽略项目根目录下的“FILE”文件，但不包括其他目录下的“FILE”文件；
 	4. build/：忽略“build/”目录下的所有文件；
 	5. /*/FILE：忽略项目根目录下所有一级目录下的“FILE”文件；
 	6. /**/FILE：忽略项目根目录下所有的“FILE”文件；



#  Git的基本命令

![Git文件状态01](/Users/luqq/Documents/02_tec-doc/Git/pics/Git文件状态03.jpeg)

git的添加至暂存区、提交至版本库、删除、回滚的操作一定是在工作目录、暂存区和本地仓库之间倒换的；

## git的别名

* git config --<system|global|local> alias.\<STRING> <COMMAND\>：使用自定义的字符串代替“git”的子命令。

## git status

### 修改了文件但示添加至暂存区时的状态

![git_status02](/Users/luqq/Documents/02_tec-doc/Git/pics/git_status02.png)

* On branch master：显示当前所在的分支为“master”；
* Changes not staged for commit：说明已跟踪文件的内容发生了变化,但还没有放到暂存区
* (use "git add \<file\>..." to update what will be committed)：提示可以使用“git add \<file\> ...”将被修改的文件加入暂存区；
* (use "git checkout -- \<file\>..." to discard changes in working directory)：提示可以使用“git checkout -- \<file\> ...”命令将已修改的文件回退到修改之前的状态，**如果执行此命令则会丢失当前的工作，慎重执行**；
* modified:   passwd：“passwd”文件已被修改，颜色为橙色或红色表示文件已修改但未加入暂存区；
* no changes added to commit (use "git add" and/or "git commit -a")：提示没有已添加至暂存区的修改要提交，可使用“git add”或“git commit -a”将本地未添加至暂存区的文件加入暂存区。

### 修改了文件并添加至暂存区时的状态

![git_status03](/Users/luqq/Documents/02_tec-doc/Git/pics/git_status03.png)

* On branch master：显示当前所在的分支为“master”；
* Changes to be committed：有已修改的文件可以提交到版本库，颜色为绿色表示文件已修改且加入暂存区；
* (use "git reset HEAD \<file\>..." to unstage)：提示用户可以使用“git reset HEAD \<file\> ...”将指定文件拿出暂存区，将暂存区回退到上一个状态；

### 一次完整的提交后的状态

![git_status04](/Users/luqq/Documents/02_tec-doc/Git/pics/git_status04.png)

![git_status01](/Users/luqq/Documents/02_tec-doc/Git/pics/git_status01.png)

* [master 40ad158]：当前提交是提交到了哪个分支上，以及对应此次提交的哈希值；

* add 2 line into passwd：此次提交的注释；

* 1 file changed, 3 insertions(+)：这次提交与上一次提交的变化；

## git add

## git rm

从版本库中删除指定文件，该操作相当于“rm \<file\>” + “git add”。

![git_rm01](/Users/luqq/Documents/02_tec-doc/Git/pics/git_rm01.png)

* On branch master：显示当前所在分支；
* Changes to be committed：已经有更改可以被提交；
* (use "git reset HEAD \<file\>..." to unstage)：提示可以使用“git reset HEAD \<file\> ...”将文件从版本库中拉回到暂存区中（但仍无法在本地查看该文件，需要执行“git checkout -- \<file\>”后才会在本地显示找回的文件）；
* deleted:    fstab：说明该文件已经从版本库中删除，显示绿色表示已回退至暂存区中。

## git mv

移动文件、目录或链接的位置或更改其文件名，该操作相当于“mv \<file>” + “git add”。

![git_mv01](/Users/luqq/Documents/02_tec-doc/Git/pics/git_mv01.png)

*状态结果参照“git rm”。*该命令执行完成后该文件已保存至暂存区但不在版本库中。

### git mv后回退

使用“git reset HEAD \<file\>”回退时“\<file\>”指定为修改前或修改后的名字均可。

1. 回退至暂存区中

   ```
   # git mv test1 test2
   # git status
       # On branch master
       # Changes to be committed:
       #   (use "git reset HEAD <file>..." to unstage)
       #
       #       renamed:    test1 -> test2
       #
   # git reset HEAD test2
   # git status
       # On branch master
       # Changes to be committed:
       #   (use "git reset HEAD <file>..." to unstage)
       #
       #       deleted:    test1
       #
       # Untracked files:
       #   (use "git add <file>..." to incluqqde in what will be committed)
       #
       #       test2
   # ll
       total 8.0K
       -rw-r--r-- 1 root root 669 Feb  2 12:02 passwd
       -rw-r--r-- 1 root root 477 Feb  2 15:31 test2
   ```

   此次回退可以看到文件名并未改回原来的名字，但通过“git status”可看出回退一次相当于删除了“test1”并加入了一个未追踪的文件“test2”。

2. 将文件从暂存区回退至本地工作目录

   **如果想把“test1”找回，可通过“git reset HEAD test1”将“test1”从版本库中拿回至暂存区。**

   ```
   # git reset HEAD test1
       Unstaged changes after reset:
       D       test1
   # git status
       # On branch master
       # Changes not staged for commit:
       #   (use "git add/rm <file>..." to update what will be committed)
       #   (use "git checkout -- <file>..." to discard changes in working directory)
       #
       #       deleted:    test1
       #
       # Untracked files:
       #   (use "git add <file>..." to include in what will be committed)
       #
       #       test2
       no changes added to commit (use "git add" and/or "git commit -a")
   # ll       
       total 8.0K
       -rw-r--r-- 1 root root 669 Feb  2 12:02 passwd
       -rw-r--r-- 1 root root 477 Feb  2 15:31 test2
   # git checkout -- test1
       # git status
       # On branch master
       # Untracked files:
       #   (use "git add <file>..." to include in what will be committed)
       #
       #       test2
       nothing added to commit but untracked files present (use "git add" to track)
   # ll
       total 12K
       -rw-r--r-- 1 root root 669 Feb  2 12:02 passwd
       -rw-r--r-- 1 root root 477 Feb  2 15:43 test1
       -rw-r--r-- 1 root root 477 Feb  2 15:31 test2
   ```

   执行完“git reset HEAD test1”可看到已从版本库中将“test1”拿回至暂存区中，再执行“git checkout -- test1”可看到文件已找回。“test2”却未删除，但显示为未追踪，说明“test2”也不在暂存区中。

## git commit

### 修改最近一次提交的消息

git commit --amend：当最近一次的提交的消息写错了，可使用“--amend”选项撤回最近的一次提交并修改其提交消息，该命令会调用默认编辑器，通过交互式的方式修改提交消息。

```
# git log 
    commit 52dd528a03a1cebae237f784c2973e31552e9841
    Author: lu qingqing <314938226@qq.com>
    Date:   Sun Feb 2 15:57:22 2020 +0800

        this is error commit.
        ......
# git commit --amend
		this is right commit.
# git log 
    commit 8e87c67bba6d93d221f843d33a03eb3994160e27
    Author: lu qingqing <314938226@qq.com>
    Date:   Sun Feb 2 15:57:22 2020 +0800

        this is right commit.
```

 **注意：修改提交消息后提交的ID也会变更。**

## 将连续多个commit整理成一个

![git_commit01](/Users/luqq/Documents/02_tec-doc/Git/pics/git_commit01.png)

1. 将“10b”，“7c2”和“7d4”进行合并，则需要选择其最早的一次提交的父提交即“8b19”，因此执行“git rebase -i 8b19b54d1”；
2. 在交互式界面选择将“7c2”和“7d4”合并到“10b”上，因此将“7c2”和“7d4”之前的“pick”修改为“s”或“squash”后保存；
3. 合并后需要对新合并的提交编辑提交信息，保存后即合并完成。

![git_commit02](/Users/luqq/Documents/02_tec-doc/Git/pics/git_commit02.png)

## git log

查看历史提交。

git log -n：“n”为对应数字，以指定显示最近几次的提交历史。

git log --pretty[=\<format>]：以指定格式显示日志信息，“format”可以有“oneline（在一行显示提交的历史消息）”，“short（以简短的方式显示提交历史即不显示提交时间）”，“medium”，“full”，“fuller”，“email”，“raw”或以指定格式显示（如：“%H”表示提交的哈希值，“%an”表示作者的名字等，详细可参照“man git-log”查找“PRETTY FORMATS”章节）等。

```
# git log --pretty=format:"%h - %an, %ar : %s" -n 2
    8e87c67 - lu qingqing, 22 minutes ago : this is right commit.
    9161c08 - lu qingqing, 53 minutes ago : modify fstab to test1.
```



查看远程版本库的历史信息：

	1. git log origin/master
 	2. git log remotes/origin/master
 	3. git log refs/remotes/origin/master

## git reflog

记录所有会引起“HEAD”指向变化的操作。

## git checkout

用于切换分支或文件到工作目录。

* git checkout -- \<FILE_NAME>：从暂存区中找到该文件并复制到工作目录，该操作会丢弃该文件已修改但未加入暂存区中的内容。

* git checkout <COMMIT_ID>：回退到当前分支的指定的一次提交上，该命令的回退会使得“HEAD”游标与分支的指向分离开，一般通过该命令回退到之前的某个版本后再创建新的分支。

  **注意：通过“git checkout <COMMIT_ID>”回退后所作的修改不属于任何一个分支，应该通过“git branch <BRANCH_NAME> <COMMIT_ID>”基于新的修改创建一个新的分支。**

## git stash

在当前工作目录中保存已修改但尚未提交至暂存区中的修改。

* git stash save "MESSAGE"：将当前已修改但尚未加入暂存区中的变更保存起来，同时写入一些提示信息。
* git stash list：列出所有的已暂存但尚未加入暂存区的变更。
* git stash pop：找回当前分支中最近一次暂存的工作内容，并从“list”列表中删除这条暂存记录。
* git stash apply [STASH_ID]：找回当前分支中最近一次暂存的变更，但不会从“list”列表中删除这条暂存记录。
* git stash drop <STASH_ID>：手动删除暂存记录；

## git tag

为当前版本状态打标签。“git”支持的标签有两种，一种是轻量级标签（lightweight）与带有附注的标签（annotated）。

* git tag <TAG_NAME>：创建一个轻量级标签，即没有附注信息。
* git tag -a <TAG_NAME> -m \<MESSAGE>：创建一个带有附注的标签。
* git tag -d <TAG_NEME>：删除本地指定标签名。
* git tag：查看当前版本库中所有的标签。
  * git tag -n：查看版本库中所有标签的同时一并显示对应的附注信息。
* git tag -l <PATTERN\>：在当前版本库中查找符合模式的“TAG”。
* git show <TAG_NAME>：可查看指定标签的详细信息。
* git push origin <TAG_NAME>：向远程仓库推送版本信息。
* git push origin --tags：向远程仓库一次性推送所有远程仓库没有的标签。
* git push origin :refs/tags/<VERSION_NAME>：删除远程仓库的指定标签。
* git push origin --delete tag <VERSION_NAME>：与上一条命令一样都可以删除远程仓库上的标签。
* git fetch origin tag <VERSION_NAME>：从远程仓库仅拉取一个标签；

## git blame

查看指定文件历史修改记录。

## git diff

查看两个文件的差异。

### 显示工作目录与暂存区内文件的差异

直接使用“git diff”即可比较工作区内文件与暂存区内文件的差异。

![git_diff01](/Users/luqq/Documents/02_tec-doc/Git/pics/git_diff01.png)

* diff --git a/t1.txt b/t1.txt：“a/t1.txt”表示工作区目录“t1.txt”，“b/t1.txt”表示暂存区目录的“t1.txt”；
* index 5baffdc..ace0f7f 100644：
* --- a/t1.txt：表示工作区内的“t1.txt”是源文件；
* +++ b/t1.txt：表示暂存区内的“t1.txt”是目标文件；
* @@ -3,6 +3,4 @@ hello python：表示源文件从第三行开始往下6行与目标文件从第三个开始往下4行是有差异的，其他的内容相同；

### 显示工作目录与某个提交之间的差异

工作区目录作为源文件。

1. git diff HEAD：比较工作区目录内所有文件与最近一次提交内的所有文件的区别；
2. git diff <COMMIT_ID>：比较当前工作区目录与某个提交内所有文件的差异。

### 显示暂存区与某个提交内的区别

暂存区目录作为源文件。

1. git diff --cached：比较暂存区目录与最新的一次提交内所有文件的差异。
2. git diff --cached [--] [\<path>...]：比较暂存区目录与最新的一次提交内指定文件的差异。
3. git diff --cached <COMMIT_ID>：比较暂存区目录与指定的一次提交内所有文件的差异。
4. git diff --cached <COMMIT_ID> [--] [\<path>...]：比较暂存区目录与指定的一次提交内指定文件的差异。

### 比较两个提交之间的差异

1. git diff <COMMIT_ID> <COMMIT_ID>：比较两个指定提交这间所有文件的差异；
2. git diff <COMMIT_ID> <COMMIT_ID> [--] [\<path>...]：比较两个指定提交这间指定文件的差异；

# git分支

“master”分支是主分支，也是生产上的主线分支。

git branch：可获取本地版本库中所有分支以及当前所处的分支；

git branch -a：列出本地版本库中所有分支、当前所处的分支和与本地仓库相关联的所有远程分支；

git branch -v：列出本地所有分支以及各分支的最后一次提交的信息。

git branch <NEW\_BRANCHE\_NAME>：创建一个新的分支，创建分支的这一刻新的分支与原分支中的所有文件均是相同的；

git checkout <BRANCH_NAME>：切换到另一分支下；

git branch -d <BRANCH_NAME>：删除指定分支，但如果这个分支自创建后有过变化但从未与其他分支合并过则无法使用“-d”选项予以删除；

git branch -D <BRANCH_NAME>：如果指定的分支自创建后有过变化但未与其他分支合并则需要使用“-D”选项予以删除分支。

git checkout -b <BRANCH_NAME>：创建一个新的分支并立即切换到这个新的分支下。

git checkout -b <BRANCH_NAME1> <BRANCH_NAME2>：新创建一个本地分支“BRANCHE_NAME1”并将其与“BRANCHE_NAME2”关联起来，而不是从“master”上的某个点开始创建新的分支。

git merge <BRANCH_NAME>：将指定分支上的内容合并到当前分支下。

![git_branch01](/Users/luqq/Documents/02_tec-doc/Git/pics/git_branch01.png)

* Updating 8e87c67..2108fbe：当前进度从“8e87c67”更新到“2108fbe”，两处字符串均表示对应的哈希值。
* Fast-forward：快进，没有冲突两个分支可以直接合并；
* test2 | 3 +++：“test2”的文件新增了3行；
* 1 file changed, 3 insertions(+)：显示一个文件被修改了，这个文件插入了3行。

git branch -v：查看所有分支最近的一次提交信息。

git fetch origin master:refs/remotes/origin/mymaster：从远程分支拉取“master”分支到本地并重命名为“mymaster”，**注意：从远程分支拉下来的分支并没有一个本地分支与之对应，因此需要创建一个本地分支与其关联起来**。

git checkout --track origin/mymaster：即可创建一个本地分支与重命名后的远程分支关联起来。

## 游标

HEAD：永远指向当前所在的分支，每次的提交都会包含其交提交的“commit id”，从而实现所有的提交形成一个链式的结构；

1. HEAD文件是一个永远指向当前分支的标识符，该文件内部并不包含“SHA-1”而是指向另一个引用的指针；
2. 当执行“commit”命令时，“git”会创建一个“commit”对象，并且将这个“commit”对象的“parent”指针设置为“HEAD”所指向的引用的“SHA-1”的值；

ORIG_HEAD：表示远程分支的指向；

FETCH_HEAD：记录远程拉取代码时代码所处的“commit id”和对应的提交信息。

## 分支合并与冲突

两个要合并的分支修改了同一个文件就会出现冲突。

### fast-forward

* 如果可能，合并分支时Git会使用fast-forward模式；
* 在这种模式下，删除分支时会丢掉分支信息；
* 合并时加上“--no-ff”（git merge --no-ff \<BRANCH_NAME>）参数会禁用“fast-forward”，这样会多出一个“commit id”；
  * 在禁用快进模式下会在文件合并后生成一个新的提交，这个新的提交即为合交提交，这种模式会保留原有分支的工作信息。
* 查看“log”可使用“git log --graph”可以使用文本图形化的方式查看提交历史。

![git_branch02](/Users/luqq/Documents/02_tec-doc/Git/pics/git_branch02.png)

# 版本回退

1. 回退到上一个版本

   * git reset --hard HEAD^

     一个“^”表示返回到上一次提交，两个“^”则表示返回到前两次提交。

   * git reset --hard HEAD~1

     “～”后的“1”表示返回到前一次提交，数字为几则表示返回到前面几次提交。

   * git reset --hard \<COMMIT_ID\>

     通过指定“\<COMMIT_ID>”回退到指定的提交。

2. 返回到当前分支的最新的提交

   * git reflog

     该命令可查看操作日志，可通过该命令找到最新的一次提交，在版本回退后可返回到该分支的最新的提交。

# 远程版本库

将已有的本地仓库推送到远程：

```
# git remote add origin <GIT_REMOTE_URL>
# git push -u origin master
```

* git remote add origin <GIT_REMOTE_URL>：将“origin”作为远程“Git”仓库的地址的别名，如果一个本地仓库与多个远程仓库相关联则别名不得重复；
* git push -u origin master：将本地“master”分支与远程仓库关联起来，并将本地“Git”仓库中的文件推送至远程仓库。
* git push --set-upstream origin develop：将本地的“develop”分支推送到远程仓库并在远程仓库上创建一个“develop”分支；
* git remote show：查看与本地版本库关联的所有远程仓库，一个本地仓库可以有多个。



在.git/config中也查查看本地分支与远程分支的对应关系：

![git_remote02](/Users/luqq/Documents/02_tec-doc/Git/pics/git_remote02.png)

以“master”为例：

	1. [branch "master"]：表示本地“master”分支；
 	2. remote = origin：表示远程版本库；
 	3. merge = refs/heads/master：表示本地“master”分支与远程的“refs/heads/master”进行合并；

## 查看远程仓库详细信息

* git remote show <REMOTE_GIT_REPO_NAME>：可查看指定远程仓库的详细信息。

![git_remote01](/Users/luqq/Documents/02_tec-doc/Git/pics/git_remote01.png)

* Fetch URL: git@192.168.3.39:luqq/git_doc.git：表示可通过“git@192.168.3.39:luqq/git_doc.git”从远程仓库拉取代码；
* Push  URL: git@192.168.3.39:luqq/git_doc.git：表示可通过“git@192.168.3.39:luqq/git_doc.git”将本地仓库中的代码推送至远程仓库；
* HEAD branch: master：表示“HEAD”指向“master”分支；
* Remote branch:master tracked：远程版本库中的分支为“master”，“tracked”表示远程仓库中的“master”已经被本地所跟踪了；
* Local branch configured for 'git pull'：本地分支已经配置成了“git pull”；
* master merges with remote master：从远程仓库拉取代码时会将远程仓库的“master”与本地仓库的“master”进行合并；
* Local ref configured for 'git push'：本地分支已经配置成了“git push”；
* master pushes to master (up to date)：从本地仓库推送代码时会将本地仓库的“master”与远程仓库的“master”进行合并，且目前已更新到最新了；

修改“push”的方式：

* matching：如果你执行“git push”但没有指定分支，它将“push”所有你本地的分支到远程仓库中对应匹配的分支（git config --global push.default matching）；
* simple：执行“git push”没有指定分支时，只有当前分支会被“push”到远程仓库（git config --global push.default simple）。

## 克隆远程版本库到本地

* git clone <REMOTE_GIT_URL> [LOCAL_NAME]：将远程版本库拉取到本地，如果的命令中指定了“LOCAL_NAME”则会以这个名字作为拉取到的本地版本库的名字；

## Git refspec

refspec的本质就是将本地分支与远程代码库中的分支关联起来，而不是通过名字的匹配进行简单的对应。

* git push -u origin master：将本地“master”分支与远程仓库关联起来，并将本地“Git”仓库中的文件推送至远程仓库。
* git push --set-upstream origin develop：将本地的“develop”分支推送到远程仓库并在远程仓库上创建一个“develop”分支；
* git checkout -b <BRANCH_NAME1> <BRANCH_NAME2>：新创建一个本地分支“BRANCHE_NAME1”并将其与“BRANCHE_NAME2”关联起来，而不是从“master”上的某个点开始创建新的分支。
* git checkout --track origin/test：执行效果与上一条命令一样。

如果本地分支与远程分支名字不同则无法使用“git push”推送代码，但可以使用“git push origin HEAD:<REMOTE_RRANCH>”或“git push origin \<SRC>:\<DEST>”将本地代码推送到远程仓库的指定分支上。

查看所有远程分支信息：

* git remote show origin

### 删除远程分支

将本地分支推送到远程，其实际命令格式如下：

​	git push origin \<SRC>:\<DEST>

* git push origin :\<DESC>：可理解为将本地的一个空的分支推送到远程，即为删除远程仓库上的分支。
* git push origin --delete <REMOTE_BRANCH>：删除远程仓库上的指定分支。

# Git协作模型

## GitFlow模型

## Git分支模型

# GitHub检索方法

1. <KEY_WORD1> ... in:readme：指定在"readme"文件中查找与关键字所匹配的所有项目；
2. starts:>1000：指定查找的项目的星数要大于1000；
3. filename:<STRING\>：指定项目中必需包含指定字符串的文件。



