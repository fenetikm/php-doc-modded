" PDV (phpDocumentor for Vim)
" ===========================
"
" Version: 1.1.4
"
" Copyright 2005 by Tobias Schlitt <toby@php.net>
" Inspired by phpDoc script for Vim by Vidyut Luther (http://www.phpcult.com/).
"
" modified by kevin olson (acidjazz@gmail.com)
"
" FURTHER modified by Trevor Suarez (Rican7) <rican7@gmail.com>


" Provided under the GPL (http://www.gnu.org/copyleft/gpl.html).
"
" This script provides functions to generate phpDocumentor conform
" documentation blocks for your PHP code. The script currently
" documents:
"
" - Classes
" - Methods/Functions
" - Attributes
"
" All of those supporting all PHP 4 and 5 syntax elements.
"
" Beside that it allows you to define default values for phpDocumentor tags
" like @version (I use $id$ here), @author, @license and so on.
"
" For function/method parameters and attributes, the script tries to guess the
" type as good as possible from PHP5 type hints or default values (array, bool,
" int, string...).
"
" You can use this script by mapping the function PhpDoc() to any
" key combination. Hit this on the line where the element to document
" resides and the doc block will be created directly above that line.
"
" Installation
" ============
"
" For example include into your .vimrc:
"
" source ~/.vim/php-doc.vim
" imap <C-o> :set paste<CR>:exe PhpDoc()<CR>:set nopaste<CR>i
"
" This includes the script and maps the combination <ctrl>+o (only in
" insert mode) to the doc function.
"
" Changelog
" =========
"
" Version 1.1.4
" -------------
" - added folding support 03/19/2008
" - fixed all the variable type regex - booleans and integers properly work now 2/28/2010
"
" Version 1.0.0
" -------------
"
"  * Created the initial version of this script while playing around with VIM
"  scripting the first time and trying to fix Vidyut's solution, which
"  resulted in a complete rewrite.
"
" Version 1.0.1
" -------------
"  * Fixed issues when using tabs instead of spaces.
"  * Fixed some parsing bugs when using a different coding style.
"  * Fixed bug with call-by-reference parameters.
"  * ATTENTION: This version already has code for the next version 1.1.0,
"  which is propably not working!
"
" Version 1.1.0 (preview)
" -------------
"  * Added foldmarker generation.
"

" Version 1.1.2
" -------------
"  * Completed foldmarker commenting for functions
"



" {{{ Globals

" After phpDoc standard
if !exists('g:pdv_cfg_CommentHead') | let g:pdv_cfg_CommentHead = "/**" | endif
if !exists('g:pdv_cfg_Comment1') | let g:pdv_cfg_Comment1 = " * " | endif
if !exists('g:pdv_cfg_Commentn') | let g:pdv_cfg_Commentn = " * " | endif
if !exists('g:pdv_cfg_CommentBlank') | let g:pdv_cfg_CommentBlank = " *" | endif
if !exists('g:pdv_cfg_CommentTail') | let g:pdv_cfg_CommentTail = " */" | endif
if !exists('g:pdv_cfg_CommentSingle') | let g:pdv_cfg_CommentSingle = "//" | endif
if !exists('g:pdv_cfg_FuncCommentEnd') | let g:pdv_cfg_FuncCommentEnd = " // End function" | endif
if !exists('g:pdv_cfg_ClassCommentEnd') | let g:pdv_cfg_ClassCommentEnd = " // End" | endif
if !exists('g:pdv_cfg_VariableTypeTag') | let g:pdv_cfg_VariableTypeTag = "@var" | endif

" Default values
if !exists('g:pdv_cfg_Type') | let g:pdv_cfg_Type = "mixed" | endif
if !exists('g:pdv_cfg_Package') | let g:pdv_cfg_Package = "" | endif
if !exists('g:pdv_cfg_Version') | let g:pdv_cfg_Version = "$id$" | endif
if !exists('g:pdv_cfg_Author') | let g:pdv_cfg_Author = "Trevor Suarez <rican7@gmail.com>" | endif
if !exists('g:pdv_cfg_Copyright') | let g:pdv_cfg_Copyright = strftime('%Y') . " Blennd" | endif
if !exists('g:pdv_cfg_License') | let g:pdv_cfg_License = "PHP Version 5.4 {@link http://www.php.net/license/}" | endif

if !exists('g:pdv_cfg_ReturnVal') | let g:pdv_cfg_ReturnVal = "void" | endif

" Wether to create tags for class docs or not
if !exists('g:pdv_cfg_createClassTags') | let g:pdv_cfg_createClassTags = 1 | endif

" Wether to create @uses tags for implementation of interfaces and inheritance
if !exists('g:pdv_cfg_Uses') | let g:pdv_cfg_Uses = 1 | endif

" Options
" Whether or not to automatically add the function end comment (1|0)
if !exists('g:pdv_cfg_autoEndFunction') | let g:pdv_cfg_autoEndFunction = 1 | endif

" Whether or not to automatically add the class end comment (1|0)
if !exists('g:pdv_cfg_autoEndClass') | let g:pdv_cfg_autoEndClass = 1 | endif

" :set paste before documenting (1|0)? Recommended.
if !exists('g:pdv_cfg_paste') | let g:pdv_cfg_paste = 1 | endif

" Wether for PHP5 code PHP4 tags should be set, like @access,... (1|0)?
if !exists('g:pdv_cfg_php4always') | let g:pdv_cfg_php4always = 1 | endif

" Wether to guess scopes after PEAR coding standards:
" $_foo/_bar() == <private|protected> (1|0)?
if !exists('g:pdv_cfg_php4guess') | let g:pdv_cfg_php4guess = 1 | endif

" If you selected 1 for the last value, this scope identifier will be used for
" the identifiers having an _ in the first place.
if !exists('g:pdv_cfg_php4guessval') | let g:pdv_cfg_php4guessval = "protected" | endif

" Whether to generate the following annotations:
if !exists('g:pdv_cfg_annotation_Package') | let g:pdv_cfg_annotation_Package = 1 | endif
if !exists('g:pdv_cfg_annotation_Version') | let g:pdv_cfg_annotation_Version = 1 | endif
if !exists('g:pdv_cfg_annotation_Author') | let g:pdv_cfg_annotation_Author = 1 | endif
if !exists('g:pdv_cfg_annotation_Copyright') | let g:pdv_cfg_annotation_Copyright = 1 | endif
if !exists('g:pdv_cfg_annotation_License') | let g:pdv_cfg_annotation_License = 1 | endif

" Whether to put an extra newline after the params
if !exists('g:pdv_cfg_newline_params') | let g:pdv_cfg_newline_params = 0 | endif

" Whether to output UltiSnips tabstops
if !exists('g:pdv_cfg_UltiSnips') | let g:pdv_cfg_UltiSnips = 0 | endif

" Whether to override the function name with something else
if !exists('g:pdv_cfg_override_funcname') | let g:pdv_cfg_override_funcname = '' | endif

" Default param description
if !exists('g:pdv_cfg_ParamDescription') | let g:pdv_cfg_ParamDescription = '' | endif

"
" Regular expressions
"

let g:pdv_re_comment = ' *\*/ *'

" (private|protected|public)
let g:pdv_re_scope = '\(private\|protected\|public\)'
" (static)
let g:pdv_re_static = '\(static\)'
" (abstract)
let g:pdv_re_abstract = '\(abstract\)'
" (final)
let g:pdv_re_final = '\(final\)'

" [:space:]*(private|protected|public|static|abstract)*[:space:]+[:identifier:]+\([:params:]\)[:space:]*:[:space:]*[:return_type:]+
let g:pdv_re_func = '^\s*\([a-zA-Z ]*\)function\s\+\([^ (]\+\)\s*(\_s*\(\%([^)]\|\_s\)*\)\_s*)\s*:\?\s*\([^ {]*\)\s*[{;]\?}\?$'
let g:pdv_re_func_sigstart = '^\s*\%([a-zA-Z ]*\)function\s\+\%([^ (]\+\)\s*('
let g:pdv_re_func_sigend = '[{;]}\?$'
let g:pdv_re_funcend = '^\s*}$'
" [:typehint:]*[:space:]*$[:identifier]\([:space:]*=[:space:]*[:value:]\)?
let g:pdv_re_param = ' *\([^ &]*\) *&\?\$\([A-Za-z_][A-Za-z0-9_]*\) *=\? *\(.*\)\?$'

" [:space:]*(private|protected|public\)[:space:]*$[:identifier:]+\([:space:]*=[:space:]*[:value:]+\)*;
let g:pdv_re_attribute = '^\s*\(\(private\|public\|protected\|var\|static\)\+\)\s*\$\([^ ;=]\+\)[ =]*\(.*\);\?$'
let g:pdv_re_const = '^\s*\(\(const\)\+\)\s*\([^ ;=]\+\)[ =]*\(.*\);\?$'

" [:spacce:]*(abstract|final|)[:space:]*(class|interface|trait)+[:space:]+\(extends ([:identifier:])\)?[:space:]*\(implements ([:identifier:][, ]*)+\)?
let g:pdv_re_class = '^\s*\([a-zA-Z]*\)\s*\(interface\|class\|trait\)\s*\([^ ]\+\)\s*\(extends\)\?\s*\([a-zA-Z0-9_]*\)\?\s*\(implements*\)\? *\([a-zA-Z0-9_ ,]*\)\?.*$'

let g:pdv_re_array  = '^\(array *(.*\|\[ *\]\)'
let g:pdv_re_int    = '^[0-9]\+'
let g:pdv_re_float  = '^\d\+\.\d\+'
let g:pdv_re_string = "['\"].*"
let g:pdv_re_bool = '\(true\|false\)'


let g:pdv_re_indent = '^\s*'

" Shortcuts for editing the text:
let g:pdv_cfg_BOL = "norm! o"
let g:pdv_cfg_EOL = ""

" }}}

" {{{ PhpDocSingle()
" Document a single line of code ( does not check if doc block already exists )

func! PhpDocSingle()
    let l:endline = line(".") + 1
    call PhpDoc()
    exe "norm! " . l:endline . "G$"
endfunc

" }}}
" {{{ PhpDocRange()
" Documents a whole range of code lines ( does not add defualt doc block to
" unknown types of lines ). Skips elements where a docblock is already
" present.
func! PhpDocRange() range
    let l:line = a:firstline
    let l:endLine = a:lastline
    let l:elementName = ""
    while l:line <= l:endLine
        " TODO: Replace regex check for existing doc with check more lines
        " above...
        if (getline(l:line) =~ g:pdv_re_func || getline(l:line) =~ g:pdv_re_attribute || getline(l:line) =~ g:pdv_re_class) && getline(l:line - 1) !~ g:pdv_re_comment
            let l:docLines = 0
            " Ensure we are on the correct line to run PhpDoc()
            exe "norm! " . l:line . "G$"
            " No matter what, this returns the element name
            let l:elementName = PhpDoc()
            let l:endLine = l:endLine + (line(".") - l:line) + 1
            let l:line = line(".") + 1
        endif
        let l:line = l:line + 1
    endwhile
endfunc

" }}}
" {{{ PhpDocFold()

" func! PhpDocFold(name)
"   let l:startline = line(".")
"   let l:currentLine = l:startLine
"   let l:commentHead = escape(g:pdv_cfg_CommentHead, "*.");
"     let l:txtBOL = g:pdv_cfg_BOL . matchstr(l:name, '^\s*')
"   " Search above for comment start
"   while (l:currentLine > 1)
"       if (matchstr(l:commentHead, getline(l:currentLine)))
"           break;
"       endif
"       let l:currentLine = l:currentLine + 1
"   endwhile
"   " Goto 1 line above and open a newline
"     exe "norm! " . (l:currentLine - 1) . "Go\<ESC>"
"   " Write the fold comment
"     exe l:txtBOL . g:pdv_cfg_CommentSingle . " {"."{{ " . a:name . g:pdv_cfg_EOL
"   " Add another newline below that
"   exe "norm! o\<ESC>"
"   " Search for our comment line
"   let l:currentLine = line(".")
"   while (l:currentLine <= line("$"))
"       " HERE!!!!
"   endwhile
"
"
" endfunc


" }}}

" {{{ PhpDoc()

func! PhpDoc()
    " Needed for my .vimrc: Switch off all other enhancements while generating docs
    let l:paste = &g:paste
    let &g:paste = g:pdv_cfg_paste == 1 ? 1 : &g:paste

    let l:line = getline(".")
    let l:func_term = search(g:pdv_re_func_sigend, 'n')
    let l:result = ""

    if l:line =~ g:pdv_re_func_sigstart
        let l:result = PhpDocFunc(l:func_term)

    elseif l:line =~ g:pdv_re_funcend
        let l:result = PhpDocFuncEnd()

    elseif l:line =~ g:pdv_re_attribute
        let l:result = PhpDocVar()

    elseif l:line =~ g:pdv_re_const
        let l:result = PhpDocConst()

    elseif l:line =~ g:pdv_re_class
        if g:pdv_cfg_createClassTags == 1
            let l:result = PhpDocClass()
        else
            let l:result = PhpDocDefault()
        endif

    else
        let l:result = PhpDocDefault()

    endif

    let &g:paste = l:paste

    return l:result
endfunc

" }}}

" {{{ PhpDocFuncEnd()
func! PhpDocFuncEnd()

    call setline(line('.'), getline('.') . g:pdv_cfg_FuncCommentEnd)
endfunc
" }}}
" {{{ PhpDocFuncEndAuto()
func! PhpDocFuncEndAuto(funcname)

    call search('{')
    call searchpair('{', '', '}')
    call setline(line('.'), getline('.') . g:pdv_cfg_FuncCommentEnd . ' ' . a:funcname)

endfunc
" }}}

" {{{ PhpDocClassEnd()
func! PhpDocClassEnd(classtype, classname)

    call setline(line('.'), getline('.') . g:pdv_cfg_ClassCommentEnd . ' ' . a:classtype . ' ' . a:classname)
endfunc
" }}}
" {{{ PhpDocClassEndAuto()
func! PhpDocClassEndAuto(classtype, classname)

    call search('{')
    call searchpair('{', '', '}')
    return PhpDocClassEnd(a:classtype, a:classname)

endfunc
" }}}

" {{{  PhpDocFunc()

func! PhpDocFunc(end_line)
    " Line for the comment to begin
    let commentline = line (".") - 1

    let l:line = getline(".")

    if 0 < a:end_line
        let l:line = join(getline(line('.'), a:end_line), ' ')
    endif

    let l:name = substitute (l:line, '^\(.*\)\/\/.*$', '\1', "")

    "exe g:pdv_cfg_BOL . "DEBUG:" . name. g:pdv_cfg_EOL

    " First some things to make it more easy for us:
    " tab -> space && space+ -> space
    " let l:name = substitute (l:name, '\t', ' ', "")
    " Orphan. We're now using \s everywhere...

    " Now we have to split DECL in three parts:
    " \[(skopemodifier\)]\(funcname\)\(parameters\)
    let l:indent = matchstr(l:name, g:pdv_re_indent)

    let l:modifier = substitute (l:name, g:pdv_re_func, '\1', "g")
    let l:funcname = substitute (l:name, g:pdv_re_func, '\2', "g")
    let l:funcname = substitute (l:funcname, '__construct', 'Constructor', "g") " Rename constructors
    let l:parameters = substitute (l:name, g:pdv_re_func, '\3', "g") . ","
    let l:params = substitute (l:name, g:pdv_re_func, '\3', "g")
    let l:params = substitute (l:params, '[$  ]', '', "g")
    let l:scope = PhpDocScope(l:modifier, l:funcname)
    let l:static = g:pdv_cfg_php4always == 1 ? matchstr(l:modifier, g:pdv_re_static) : ""
    let l:abstract = g:pdv_cfg_php4always == 1 ? matchstr(l:modifier, g:pdv_re_abstract) : ""
    let l:final = g:pdv_cfg_php4always == 1 ? matchstr(l:modifier, g:pdv_re_final) : ""
    let l:returnType = substitute (l:name, g:pdv_re_func, '\4', "g")

    if l:returnType == ""
        let l:returnType = g:pdv_cfg_ReturnVal
    endif

    exe "norm! " . commentline . "G$"

    " Local indent
    let l:txtBOL = g:pdv_cfg_BOL . l:indent

    " exec l:txtBOL . "// " . l:scope ." ".  funcname . "(" . l:params . ") {{" . "{ " . g:pdv_cfg_EOL

    exe l:txtBOL . g:pdv_cfg_CommentHead . g:pdv_cfg_EOL

    if g:pdv_cfg_override_funcname != ''
        let l:funcname = g:pdv_cfg_override_funcname
    endif

    if g:pdv_cfg_UltiSnips == 1
        let l:pdv_cfg_UltiSnips_i = 2
        let l:funcname = '${1:' . l:funcname . '}'
    endif

    " added folding
    exe l:txtBOL . g:pdv_cfg_Comment1 . funcname . g:pdv_cfg_EOL
    exe l:txtBOL . g:pdv_cfg_CommentBlank . g:pdv_cfg_EOL

    let l:_haveParams = 0

    while (l:parameters != ",") && (l:parameters != "")
       let _haveParams = 1
        " Save 1st parameter
        let _p = substitute (l:parameters, '\([^,]*\) *, *\(.*\)', '\1', "")
        " Remove this one from list
        let l:parameters = substitute (l:parameters, '\([^,]*\) *, *\(.*\)', '\2', "")
        " PHP5 type hint?
        let l:paramtype = substitute (_p, g:pdv_re_param, '\1', "")
        " Parameter name
        let l:paramname = substitute (_p, g:pdv_re_param, '\2', "")
        " Parameter default
        let l:paramdefault = substitute (_p, g:pdv_re_param, '\3', "")

        if l:paramtype == ""
            let l:paramtype = PhpDocType(l:paramdefault)
        endif

        if l:paramtype != ""
            let l:paramtype = " " . l:paramtype
        endif
        exe l:txtBOL . g:pdv_cfg_Commentn . "@param" . l:paramtype . " $" . l:paramname . ""

        let l:param_description = ""
        if g:pdv_cfg_ParamDescription != ""
            let l:param_description = g:pdv_cfg_ParamDescription
        endif

        if g:pdv_cfg_UltiSnips == 1
            if l:param_description == ""
                let l:param_description = "$" . l:pdv_cfg_UltiSnips_i
            else
                let l:param_description = "${" . l:pdv_cfg_UltiSnips_i . ":" . l:param_description . "}"
            endif
            let l:pdv_cfg_UltiSnips_i = l:pdv_cfg_UltiSnips_i + 1
        endif

        exe "norm! A " . l:param_description . "" . g:pdv_cfg_EOL

    endwhile

    if l:_haveParams == 1 && g:pdv_cfg_newline_params == 1
        exe l:txtBOL . g:pdv_cfg_CommentBlank
    endif

    if l:static != ""
        exe l:txtBOL . g:pdv_cfg_Commentn . "@static" . g:pdv_cfg_EOL
    endif
    if l:abstract != ""
        exe l:txtBOL . g:pdv_cfg_Commentn . "@abstract" . g:pdv_cfg_EOL
    endif
    if l:final != ""
        exe l:txtBOL . g:pdv_cfg_Commentn . "@final" . g:pdv_cfg_EOL
    endif
    if l:scope != ""
        exe l:txtBOL . g:pdv_cfg_Commentn . "@access " . l:scope . g:pdv_cfg_EOL
    endif
    if l:funcname != "Constructor"
        exe l:txtBOL . g:pdv_cfg_Commentn . "@return " . l:returnType . g:pdv_cfg_EOL
    endif

    " Close the comment block.
    exe l:txtBOL . g:pdv_cfg_CommentTail . g:pdv_cfg_EOL

    if g:pdv_cfg_autoEndFunction == 1
        return l:modifier ." ". l:funcname . PhpDocFuncEndAuto(l:funcname)
    else
        return l:modifier ." ". l:funcname
    endif
endfunc

" }}}
" {{{  PhpDocVar()

func! PhpDocVar()
    " Line for the comment to begin
    let commentline = line (".") - 1

    let l:name = substitute (getline ("."), '^\(.*\)\/\/.*$', '\1', "")

    " Now we have to split DECL in three parts:
    " \[(skopemodifier\)]\(funcname\)\(parameters\)
    " let l:name = substitute (l:name, '\t', ' ', "")
    " Orphan. We're now using \s everywhere...

    let l:indent = matchstr(l:name, g:pdv_re_indent)

    let l:modifier = substitute (l:name, g:pdv_re_attribute, '\1', "g")
    let l:varname = substitute (l:name, g:pdv_re_attribute, '\3', "g")
    let l:default = substitute (l:name, g:pdv_re_attribute, '\4', "g")
    let l:scope = PhpDocScope(l:modifier, l:varname)

    let l:static = g:pdv_cfg_php4always == 1 ? matchstr(l:modifier, g:pdv_re_static) : ""

    let l:type = PhpDocType(l:default)

    exe "norm! " . commentline . "G$"

    " Local indent
    let l:txtBOL = g:pdv_cfg_BOL . l:indent

    exe l:txtBOL . g:pdv_cfg_CommentHead . g:pdv_cfg_EOL
    exe l:txtBOL . g:pdv_cfg_Comment1 . l:varname . " " . g:pdv_cfg_EOL
    exe l:txtBOL . g:pdv_cfg_CommentBlank . g:pdv_cfg_EOL
    if l:static != ""
        exe l:txtBOL . g:pdv_cfg_Commentn . "@static" . g:pdv_cfg_EOL
    endif
    exe l:txtBOL . g:pdv_cfg_Commentn . g:pdv_cfg_VariableTypeTag . " " . l:type . g:pdv_cfg_EOL
    if l:scope != ""
        exe l:txtBOL . g:pdv_cfg_Commentn . "@access " . l:scope . g:pdv_cfg_EOL
    endif

    " Close the comment block.
    exe l:txtBOL . g:pdv_cfg_CommentTail . g:pdv_cfg_EOL
    return l:modifier ." ". l:varname
endfunc

" }}}
" {{{  PhpDocConst()

func! PhpDocConst()
    " Line for the comment to begin
    let commentline = line (".") - 1

    let l:name = substitute (getline ("."), '^\(.*\)\/\/.*$', '\1', "")

    " Now we have to split DECL in three parts:
    " \[(skopemodifier\)]\(funcname\)\(parameters\)
    " let l:name = substitute (l:name, '\t', ' ', "")
    " Orphan. We're now using \s everywhere...

    let l:indent = matchstr(l:name, g:pdv_re_indent)

    let l:modifier = substitute (l:name, g:pdv_re_const, '\1', "g")
    let l:varname = substitute (l:name, g:pdv_re_const, '\3', "g")
    let l:default = substitute (l:name, g:pdv_re_const, '\4', "g")
    let l:scope = PhpDocScope(l:modifier, l:varname)

    let l:static = g:pdv_cfg_php4always == 1 ? matchstr(l:modifier, g:pdv_re_static) : ""

    let l:type = PhpDocType(l:default)

    exe "norm! " . commentline . "G$"

    " Local indent
    let l:txtBOL = g:pdv_cfg_BOL . l:indent

    exe l:txtBOL . g:pdv_cfg_CommentHead . g:pdv_cfg_EOL
    exe l:txtBOL . g:pdv_cfg_Comment1 . l:varname . " " . g:pdv_cfg_EOL
    exe l:txtBOL . g:pdv_cfg_CommentBlank . g:pdv_cfg_EOL
    exe l:txtBOL . g:pdv_cfg_Commentn . g:pdv_cfg_VariableTypeTag . " " . l:type . g:pdv_cfg_EOL

    " Close the comment block.
    exe l:txtBOL . g:pdv_cfg_CommentTail . g:pdv_cfg_EOL
    return l:modifier ." ". l:varname
endfunc

" }}}
"  {{{  PhpDocClass()

func! PhpDocClass()
    " Line for the comment to begin
    let commentline = line (".") - 1

    let l:name = substitute (getline ("."), '^\(.*\)\/\/.*$', '\1', "")

    "exe g:pdv_cfg_BOL . "DEBUG:" . name. g:pdv_cfg_EOL

    " First some things to make it more easy for us:
    " tab -> space && space+ -> space
    " let l:name = substitute (l:name, '\t', ' ', "")
    " Orphan. We're now using \s everywhere...

    " Now we have to split DECL in three parts:
    " \[(skopemodifier\)]\(classname\)\(parameters\)
    let l:indent = matchstr(l:name, g:pdv_re_indent)

    let l:modifier = substitute (l:name, g:pdv_re_class, '\1', "g")
    let l:classtype = substitute (l:name, g:pdv_re_class, '\2', "g")
    let l:classname = substitute (l:name, g:pdv_re_class, '\3', "g")
    let l:extends = g:pdv_cfg_Uses == 1 ? substitute (l:name, g:pdv_re_class, '\5', "g") : ""
    let l:interfaces = g:pdv_cfg_Uses == 1 ? substitute (l:name, g:pdv_re_class, '\7', "g") . "," : ""

    let l:abstract = g:pdv_cfg_php4always == 1 ? matchstr(l:modifier, g:pdv_re_abstract) : ""
    let l:final = g:pdv_cfg_php4always == 1 ?  matchstr(l:modifier, g:pdv_re_final) : ""

    exe "norm! " . commentline . "G$"

    " Local indent
    let l:txtBOL = g:pdv_cfg_BOL . l:indent

    exe l:txtBOL . g:pdv_cfg_CommentHead . g:pdv_cfg_EOL
    exe l:txtBOL . g:pdv_cfg_Comment1 . l:classname . g:pdv_cfg_EOL
    exe l:txtBOL . g:pdv_cfg_CommentBlank . g:pdv_cfg_EOL
    if l:extends != "" && l:extends != "implements"
        exe l:txtBOL . g:pdv_cfg_Commentn . "@uses " . l:extends . g:pdv_cfg_EOL
    endif

    while (l:interfaces != ",") && (l:interfaces != "")
        " Save 1st parameter
        let interface = substitute (l:interfaces, '\([^, ]*\) *, *\(.*\)', '\1', "")
        " Remove this one from list
        let l:interfaces = substitute (l:interfaces, '\([^, ]*\) *, *\(.*\)', '\2', "")
        exe l:txtBOL . g:pdv_cfg_Commentn . "@uses " . l:interface . g:pdv_cfg_EOL
    endwhile

    if l:abstract != ""
        exe l:txtBOL . g:pdv_cfg_Commentn . "@abstract" . g:pdv_cfg_EOL
    endif
    if l:final != ""
        exe l:txtBOL . g:pdv_cfg_Commentn . "@final" . g:pdv_cfg_EOL
    endif
    if g:pdv_cfg_annotation_Package == 1
        exe l:txtBOL . g:pdv_cfg_Commentn . "@package " . g:pdv_cfg_Package . g:pdv_cfg_EOL
    endif
    if g:pdv_cfg_annotation_Version == 1
        exe l:txtBOL . g:pdv_cfg_Commentn . "@version " . g:pdv_cfg_Version . g:pdv_cfg_EOL
    endif
    if g:pdv_cfg_annotation_Copyright == 1
        exe l:txtBOL . g:pdv_cfg_Commentn . "@copyright " . g:pdv_cfg_Copyright . g:pdv_cfg_EOL
    endif
    if g:pdv_cfg_annotation_Author == 1
        exe l:txtBOL . g:pdv_cfg_Commentn . "@author " . g:pdv_cfg_Author . g:pdv_cfg_EOL
    endif
    if g:pdv_cfg_annotation_License == 1
        exe l:txtBOL . g:pdv_cfg_Commentn . "@license " . g:pdv_cfg_License . g:pdv_cfg_EOL
    endif

    " Close the comment block.
    exe l:txtBOL . g:pdv_cfg_CommentTail . g:pdv_cfg_EOL

    if g:pdv_cfg_autoEndClass == 1
        return l:modifier ." ". l:classname . PhpDocClassEndAuto(l:classtype, l:classname)
    else
        return l:modifier ." ". l:classname
    endif
endfunc

" }}}
" {{{ PhpDocScope()

func! PhpDocScope(modifiers, identifier)
    " exe g:pdv_cfg_BOL . DEBUG: . a:modifiers . g:pdv_cfg_EOL
    let l:scope  = ""
    if  matchstr (a:modifiers, g:pdv_re_scope) != ""
        if g:pdv_cfg_php4always == 1
            let l:scope = matchstr (a:modifiers, g:pdv_re_scope)
        else
            let l:scope = "x"
        endif
    endif
    if l:scope =~ "^\s*$" && g:pdv_cfg_php4guess
        if a:identifier[0] == "_"
            let l:scope = g:pdv_cfg_php4guessval
        else
            let l:scope = "public"
        endif
    endif
    return l:scope != "x" ? l:scope : ""
endfunc

" }}}
" {{{ PhpDocType()

func! PhpDocType(typeString)
    let l:type = ""
    if a:typeString =~ g:pdv_re_array
        let l:type = "array"
    endif
    if a:typeString =~ g:pdv_re_int
        let l:type = "int"
    endif
    if a:typeString =~ g:pdv_re_float
        let l:type = "float"
    endif
    if a:typeString =~ g:pdv_re_string
        let l:type = "string"
    endif
    if a:typeString =~ g:pdv_re_bool
        let l:type = "bool"
    endif
    if l:type == ""
        let l:type = g:pdv_cfg_Type
    endif
    return l:type
endfunc

"  }}}
" {{{  PhpDocDefault()

func! PhpDocDefault()
    " Line for the comment to begin
    let commentline = line (".") - 1

    let l:indent = matchstr(getline("."), '^\ *')

    exe "norm! " . commentline . "G$"

    " Local indent
    let l:txtBOL = g:pdv_cfg_BOL . indent

    exe l:txtBOL . g:pdv_cfg_CommentHead . g:pdv_cfg_EOL
    exe l:txtBOL . g:pdv_cfg_CommentBlank . " " . g:pdv_cfg_EOL

    " Close the comment block.
    exe l:txtBOL . g:pdv_cfg_CommentTail . g:pdv_cfg_EOL
endfunc

" }}}
