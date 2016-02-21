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
/* ��ȡ��ǰ���ļ���*/
macro _wcjCurrentFileName()
{
	hbuf = GetCurrentBuf()	
    fullname = GetBufName(hbuf)  

	return _wcjFileName(fullname)
}

/*ͷ�ļ���������*/
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

/*��ȡ��ǰʱ��*/
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

	/* ���ù����ȷ��λ�� */
	SetBufIns(hbuf, ln, 0)
	
	return true
}

/*�ڵ�ǰ�е�ǰһ�����ע��*/
macro _wcjCommentBefore()
{
	hbuf = GetCurrentBuf()
	ln 	 = GetBufLnCur(hbuf)

	comment = ""

	/*����ո�*/
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

	/* ���ù����ȷ��λ�� */
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

	/* ���ù����ȷ��λ�� */
	SetBufIns(hbuf, cursorln, 4)	
}
macro _wcjHandleNewFile(key)
{
	/*����C��׼��include�ļ�����*/
	if (key == "newinc")	return _wcjNewFile(true)
	/*����C��׼��C�ļ�����*/
	if (key == "newc")		return _wcjNewFile(false)

	return false
}

/**************************************ufp type related***********************************************/
macro _wcjInsertCursorText(data)
{
	/* ���ָ�����ı� */
	hbuf = GetCurrentBuf()
	ln = GetBufLnCur(hbuf)
	text = GetBufLine(hbuf, ln)

	/* ��ù��λ�� */
	hwnd = GetCurrentWnd()
	sel	 = GetWndSel(hwnd)
	column = sel.ichFirst
	
	/* Ϊ��ǰλ�ò�����ȷ���� */
	DelBufLine(hbuf, ln)
	before = strtrunc(text, column)
	after  = strmid(text, column, strlen(text))
	newtext = "@before@@data@@after@"	
	InsBufLine(hbuf, ln, newtext)

	/* ���ù����ȷ��λ�� */
	pos = column + strlen(data)
	SetBufIns(hbuf, ln, pos)	
}
/*������ݲ���*/
macro _wcjHandleUfpType(key)
{
	/*key = Ask("Enter ufp type short key");*/
	ufptype = _wcjGetUfpType(key)
	if (ufptype == "")
		return false;
	
	_wcjInsertCursorText(ufptype);

	return true;
}

/**************************************macro related***********************************************/
/*����ifdef*/
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

/*����if*/
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

	/* ��ù��λ�� */
	hwnd = GetCurrentWnd()
	sel	 = GetWndSel(hwnd)
	column = sel.ichFirst

	/*�ҵ���ȷ�ķ���*/
	//symbol = GetSymbolLocationFromLn(hbuf, ln)
	symbol = GetSymbolFromCursor(hbuf, ln, column)
	if (symbol.Symbol == "")
	{
		msg("check cursor, can't find symbol")
		return true
	}

	/*�ļ�����ȡ*/	
	filename = _wcjFileName(symbol.file);
	len = strlen(filename)
	filetype = strmid(filename, len-2, len)
	if (filetype == ".c")
		filename = Ask("func imp in @filename@, enter include file name or cancel:")

	if (filename == "")
		return true

	includetext = "#include \"@filename@\""
	
	/* ��ȷ�Ĳ���λ�� */
	count = GetBufLineCount(hbuf)
	ln = 0
	text = ""
	lasttext = "invalid"
	while(ln < count)
	{
		if(ln != 0)
			lasttext = text
		text = GetBufLine(hbuf, ln)

		/*�ҵ�����λ��*/
		if (text == "#ifdef _cplusplus")
		{
			/*��֤����һ���ո�*/
			if (lasttext == "")
				ln--
			else
				InsBufLine(hbuf, ln, "")
				
			/* ���� */
			InsBufLine(hbuf, ln, includetext)

			return true						
		}

		/*�����*/
		if (text == includetext)
		{
			return true
		}
		
		ln++
	}
	
	msg("can't add include, do it by youself")
	return true
}

macro _wcjHandleVar()
{
	key = Ask("Enter variable name:")
	if (key == "")
		return true
	 
	hbuf = GetCurrentBuf()

	text = ""
	if (strtrunc(key, 1) == "i")				text = "UFP_INT32 @key@"
	if (strtrunc(key, 2) == "ui")				text = "UFP_UINT32 @key@"
	if (strtrunc(key, 3) == "ull")				text = "UFP_UINT64 @key@"
	if (strtrunc(key, 2) == "uv")				text = "UFP_UINTPTR @key@"
	if (strtrunc(key, 1) == "v")				text = "UFP_VOID @key@"
	if (strtrunc(key, 2) == "vp")				text = "UFP_PHYS_ADDR @key@"
	if (strtrunc(key, 1) == "n")				text = "UFP_NULL_PTR @key@"
	
	_wcjInsertCursorText(text)

	return true	
}

/**************************************�������п�ݼ�***********************************************/
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

/*�������õ����Զ����ݼ�*/
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


/* ����� */
macro wcjMain()
{
	key = Ask("Enter anthing you want:")
	if (key == "")
		return ""

	key = tolower(key);
	
	/*ufp type����*/
	if (_wcjHandleUfpType(key))			return ""
	/*macro���*/
	if (_wcjHandleMacro(key))			return ""
	/*new file*/
	if (_wcjHandleNewFile(key))			return ""			
	/*comment*/
	if (_wcjHandleComment(key))			return ""
	/*�������*/
	if (_wcjHandleWindows(key))			return ""
	/*����*/
	if (key == "var")					return _wcjHandleVar()
	
	return _wcjHandleOther(key)
}

