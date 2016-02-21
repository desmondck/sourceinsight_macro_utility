macro _wcjFileName(fullname)
{
    length = strlen(fullname) 
	if (length == 0)
		return ""

    index = length
    while ("\\" !=  fullname[--index]);

	purename = ""
	while (index < length)
		purename = cat(purename, fullname[++index])
		
    return purename	
}
/* 获取当前的文件名*/
macro _wcjCurrentFileName()
{
	hbuf = GetCurrentBuf()	
    fullname = GetBufName(hbuf)  

	return _wcjFileName(fullname)
}

/*头文件定义名称*/
macro wcjIncDefName()
{
	filename = _wcjCurrentFileName();
	length = strlen(filename);

	defname = "__"
	index = 0;
	while (index < length)
	{
		if (filename[index] == ".")
			defname = cat(defname, "_")
		else
			defname = cat(defname, toupper(filename[index]))

		++index
	}

	defname = cat(defname, "__")

	return defname
}

/*获取当前时间*/
macro wcjGetTime()
{
    var  year
    var  month
    var  day
    var  commTime
    var  sysTime

    sysTime = GetSysTime(1)
    year = sysTime.Year
    month = sysTime.month
    day = sysTime.day
    commTime = "@year@-@month@-@day@"
    return commTime
}

/**************************************new file related***********************************************/
macro _wcjCommentFile()
{
	szMyName = "wangchunjie w00361341"
	
	hbuf = GetCurrentBuf()
	ln = 0
	InsBufLine(hbuf, ln++, "/*-------------------------------------------------------------------------")
	InsBufLine(hbuf, ln++, cat("	File: 	", _wcjCurrentFileName())
	InsBufLine(hbuf, ln++, cat("	Author: ", szMyName))
	InsBufLine(hbuf, ln++, cat("	Date: 	", wcjGetTime())
	InsBufLine(hbuf, ln++, cat("	Desc: 	", ""))
	InsBufLine(hbuf, ln++, "-------------------------------------------------------------------------*/")

	/* 设置光标正确的位置 */
	SetBufIns(hbuf, ln, 0)
	
	return true
}

/*在当前行的前一行添加注释*/
macro _wcjCommentBefore()
{
	hbuf = GetCurrentBuf()
	ln 	 = GetBufLnCur(hbuf)

	comment = ""

	/*补足空格*/
	text = GetBufLine(hbuf, ln)
	index = 0
	while (true) 
	{
		c = text[index++]
		if (c != " " && c != "	")
			break;
			
		comment = cat(comment, c)	
	}
	
	comment = cat(comment, "/**<  */")
		
	InsBufLine(hbuf, ln, comment)

	/* 设置光标正确的位置 */
	SetBufIns(hbuf, ln, strlen(comment) - 3)
	
	return true
}

macro _wcjCommentHeader()
{
	hbuf = GetCurrentBuf()

	szFunc = GetCurSymbol()
	ln = GetSymbolLine(szFunc)
	SetBufIns(hbuf, ln, 0)
	
	return _wcjCommentBefore()
}


/**************************************new file related***********************************************/
macro _wcjNewFile(bInc)
{
	defname = wcjIncDefName()

	_wcjCommentFile()
	
	hbuf = GetCurrentBuf()
	ln 	 = GetBufLnCur(hbuf)

	if (bInc) 
	{
		InsBufLine(hbuf, ln++, "#ifndef @defname@")
		InsBufLine(hbuf, ln++, "#define @defname@")
		InsBufLine(hbuf, ln++, "")		
	}

	InsBufLine(hbuf, ln++, "#ifdef _cplusplus")
	InsBufLine(hbuf, ln++, "#if _cplusplus")
	InsBufLine(hbuf, ln++, "extern \"C\"{")
	InsBufLine(hbuf, ln++, "#endif")
	InsBufLine(hbuf, ln++, "#endif")	

	InsBufLine(hbuf, ln++, "")
	cursorln = ln
	InsBufLine(hbuf, ln++, "")
	InsBufLine(hbuf, ln++, "")
	
	InsBufLine(hbuf, ln++, "#ifdef _cplusplus")
	InsBufLine(hbuf, ln++, "#if _cplusplus")
	InsBufLine(hbuf, ln++, "}")
	InsBufLine(hbuf, ln++, "#endif")
	InsBufLine(hbuf, ln++, "#endif")	

	if (bInc)
		InsBufLine(hbuf, ln++, "#endif /* @defname@ */")

	/* 设置光标正确的位置 */
	SetBufIns(hbuf, cursorln, 4)	
}
macro _wcjHandleNewFile(key)
{
	/*插入C标准的include文件内容*/
	if (key == "newinc")	return _wcjNewFile(true)
	/*插入C标准的C文件内容*/
	if (key == "newc")		return _wcjNewFile(false)

	return false
}

/**************************************ufp type related***********************************************/
/*快捷内容插入*/
macro _wcjHandleUfpType(key)
{
	/*key = Ask("Enter ufp type short key");*/
	ufptype = _wcjGetUfpType(key)
	if (ufptype == "")
		return false;
	
	/* 获得指定行文本 */
	hbuf = GetCurrentBuf()
	ln = GetBufLnCur(hbuf)
	text = GetBufLine(hbuf, ln)

	/* 获得光标位置 */
	hwnd = GetCurrentWnd()
	sel	 = GetWndSel(hwnd)
	column = sel.ichFirst
	
	/* 为当前位置插入正确内容 */
	DelBufLine(hbuf, ln)
	before = strtrunc(text, column)
	after  = strmid(text, column, strlen(text))
	newtext = "@before@@ufptype@@after@"	
	InsBufLine(hbuf, ln, newtext)

	/* 设置光标正确的位置 */
	pos = column + strlen(ufptype)
	SetBufIns(hbuf, ln, pos)

	return true;
}

/**************************************macro related***********************************************/
/*插入ifdef*/
macro _wcjIfdefSz()
{
	data = Ask("Enter ifdef condition:")
	if (data == "")
		return true
		
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	lnLast = GetWndSelLnLast(hwnd)
	 
	hbuf = GetCurrentBuf()
	InsBufLine(hbuf, lnFirst, "#ifdef @data@")
	InsBufLine(hbuf, lnLast+2, "#endif /* @data@ */")

	return true
}

/*插入if*/
macro _wcjIfSz(data)
{
	hwnd = GetCurrentWnd()
	lnFirst = GetWndSelLnFirst(hwnd)
	lnLast = GetWndSelLnLast(hwnd)
	 
	hbuf = GetCurrentBuf()
	InsBufLine(hbuf, lnFirst, "#if @data@")
	InsBufLine(hbuf, lnLast+2, "#endif")

	return true
}

/**************************************windows related***********************************************/
macro _wcjCloseWindows()
{
    cwnd = WndListCount()  
    iwnd = 0  
    while (1)  
    {  
        hwnd = WndListItem(0)  
        hbuf = GetWndBuf(hwnd)  
        SaveBuf(hbuf)  
        CloseWnd(hwnd)  
        iwnd = iwnd + 1  
        if(iwnd >= cwnd)  
            break  
    }  

    return true;
}

/**************************************other related***********************************************/
macro _wcjAddInclude()
{
	hbuf = GetCurrentBuf()
	ln = GetBufLnCur(hbuf)

	/* 获得光标位置 */
	hwnd = GetCurrentWnd()
	sel	 = GetWndSel(hwnd)
	column = sel.ichFirst

	/*找到正确的符号*/
	//symbol = GetSymbolLocationFromLn(hbuf, ln)
	symbol = GetSymbolFromCursor(hbuf, ln, column)
	if (symbol.Symbol == "")
	{
		msg("check cursor, can't find symbol")
		return true
	}

	/*文件名抽取*/	
	filename = _wcjFileName(symbol.file);
	len = strlen(filename)
	filetype = strmid(filename, len-2, len)
	if (filetype == ".c")
		filename = Ask("func imp in @filename@, enter include file name or cancel:")

	if (filename == "")
		return true

	includetext = "#include \"@filename@\""
	
	/* 正确的插入位置 */
	count = GetBufLineCount(hbuf)
	ln = 0
	text = ""
	lasttext = "invalid"
	while(ln < count)
	{
		if(ln != 0)
			lasttext = text
		text = GetBufLine(hbuf, ln)

		/*找到合适位置*/
		if (text == "#ifdef _cplusplus")
		{
			/*保证保留一个空格*/
			if (lasttext == "")
				ln--
			else
				InsBufLine(hbuf, ln, "")
				
			/* 插入 */
			InsBufLine(hbuf, ln, includetext)

			return true						
		}

		/*已添加*/
		if (text == includetext)
		{
			return true
		}
		
		ln++
	}
	
	msg("can't add include, do it by youself")
	return true
}

/**************************************罗列所有快捷键***********************************************/
macro _wcjHandleWindows(key)  
{  
	if (key == "winclose" || key == "wc")	return _wcjCloseWindows()

	return false;
} 
macro _wcjHandleOther(key)
{
	if (key == "addinc")		return _wcjAddInclude()

	return false
}

macro _wcjHandleMacro(key)
{
	if (key == "if0")		return _wcjIfSz(0)	
	if (key == "ifdef")		return _wcjIfdefSz()

	return false
}
macro _wcjHandleComment(key)
{
	if (key == "commentfile" || key == "cf")							return _wcjCommentFile()
	if (key == "commentbefore" || key == "commentbef" || key == "cb")	return _wcjCommentBefore()
	if (key == "commentheader" || key == "ch")							return _wcjCommentHeader()

	return false
}

/*程序中用到的自定义快捷键*/
macro _wcjGetUfpType(key)
{
	key = tolower(key);
	
	if (key == "i")					return "UFP_INT32"
	if (key == "ui" || key=="u")	return "UFP_UINT32"
	if (key == "ull")				return "UFP_UINT64"
	if (key == "uv")				return "UFP_UINTPTR"
	if (key == "v")					return "UFP_VOID"
	if (key == "vp")				return "UFP_PHYS_ADDR"
	if (key == "n")					return "UFP_NULL_PTR"
	
	
	return ""
}


/* 主入口 */
macro wcjMain()
{
	key = Ask("Enter anthing you want:")
	if (key == "")
		return ""

	key = tolower(key);
	
	/*ufp type处理*/
	if (_wcjHandleUfpType(key))			return ""
	/*macro相关*/
	if (_wcjHandleMacro(key))			return ""
	/*new file*/
	if (_wcjHandleNewFile(key))			return ""			
	/*comment*/
	if (_wcjHandleComment(key))			return ""
	/*窗体相关*/
	if (_wcjHandleWindows(key))			return ""
	
	return _wcjHandleOther(key)
}

