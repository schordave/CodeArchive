/*
    mSLSpell A light-weight wrapper for Hunspell for mIRC.
    Copyright (C) 2013 <davidschor@zigwap.com>
    
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/
#define _CRT_SECURE_NO_WARNINGS
#include "hunspell.hxx"
#include "mSLSpell.h"

static char dictionary[MAX_PATH+1];
static char affix[MAX_PATH+1];
static Hunspell *speller;
static char **resultList;
static int resultLen;
 
/* Keep this lib loaded so that we save the overhead of loading again */
void __declspec(dllexport) __stdcall LoadDll(struct LOADINFO*i)
{
    i->mKeep = TRUE; /* should be true by default, but I don't trust khaled */

    dictionary[0] = '\0';
    affix[0] = '\0';
    speller = NULL;
    resultList = NULL;
}
int __declspec(dllexport) __stdcall UnloadDll(int mTimeout)
{
    if (mTimeout == 0 || mTimeout == 2)
    {
        if (resultList)
            speller->free_list(&resultList, resultLen);

        if (speller)
            delete speller;
        return 0;
    }
    return 1;
}

static BOOL exists(LPCTSTR szPath)
{
  DWORD dwAttrib = GetFileAttributes(szPath);

  return (dwAttrib != INVALID_FILE_ATTRIBUTES && 
         !(dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
}

MSL_FUNCTION(hunspell_set_dictionary)
{
    if (*data == '\0')
    {
        strcpy(data, "//echo -sc info * mSLSpell - /set_dictionary: Missing Dictionary File | halt");
        return EXECUTECMD;
    }
    else
    {
        size_t size = strlen(data);
        if (size < 5 || strcmp(data + size - 4, ".dic") || !exists(data))
        {
            strcpy(data, "//echo -sc info * mSLSpell - /set_dictionary: Invalid Dictionary File | halt");
            return EXECUTECMD;
        }

        if (size > MAX_PATH)
        {
            strcpy(data, "//echo -sc info * mSLSpell - /set_dictionary: Invalid Dictionary File - Path Too Long | halt");
            return EXECUTECMD;
        }
    }

    strcpy(dictionary, data);
    return CONTINUE;
}


MSL_FUNCTION(hunspell_set_affix)
{
    if (*data == '\0')
    {
        strcpy(data, "//echo -sc info * mSLSpell - /set_affix: Missing Dictionary File | halt");
        return EXECUTECMD;
    }
    else
    {
        size_t size = strlen(data);
        if (size < 5 || strcmp(data + size - 4, ".aff") || !exists(data))
        {
            strcpy(data, "//echo -sc info * mSLSpell - /set_affix: Invalid Affix File | halt");
            return EXECUTECMD;
        }

        if (size > MAX_PATH)
        {
            strcpy(data, "//echo -sc info * mSLSpell - /set_affix: Invalid Affix File - Path Too Long | halt");
            return EXECUTECMD;
        }
    }

    strcpy(affix, data);
    return CONTINUE;
}

MSL_FUNCTION(hunspell_has_dictionary)
{
    strcpy(data, *dictionary ? "$true" : "$false");
    return RETURNVAL;
}

MSL_FUNCTION(hunspell_has_affix)
{
    strcpy(data, *affix ? "$true" : "$false");
    return RETURNVAL;
}


MSL_FUNCTION(hunspell_inited)
{
    strcpy(data, speller ? "$true" : "$false");
    return RETURNVAL;
}

MSL_FUNCTION(hunspell_initialize)
{
    if (!*dictionary)
    {
        strcpy(data, "//echo -sc info * mSLSpell - /hunspell_initialize: Missing Dictionary File | halt");
        return EXECUTECMD;
    }

    if (!*affix)
    {
        strcpy(data, "//echo -sc info * mSLSpell - /hunspell_initialize: Missing Affix File | halt");
        return EXECUTECMD;
    }

    if (speller)
    {
        strcpy(data, "//echo -sc info * mSLSpell - /hunspell_initialize: Hunspell Engine Already Initialized | halt");
        return EXECUTECMD;
    }

    speller = new Hunspell(affix, dictionary);
    if (!speller)
    {
        strcpy(data, "//echo -sc info * mSLSpell - /hunspell_initialize: Error Creating Hunspell Engine | halt");
        return EXECUTECMD;
    }

    if (!show)
    {
        strcpy(data, "//echo -sc info * mSLSpell - Hunspell Engine Ready");
        return EXECUTECMD;
    }
    
    resultList = NULL;
    resultLen = 0;
    return CONTINUE;
}

MSL_FUNCTION(hunspell_uninitialize)
{
    if (!speller)
    {
        strcpy(data, "//echo -sc info * mSLSpell - /hunspell_spell: Hunspell Engine Already Uninitialized | halt");
        return EXECUTECMD;
    }

    if (resultList)
        speller->free_list(&resultList, resultLen);

    if (speller)
        delete speller;

    resultList = NULL;
    resultLen = 0;
    speller = NULL;

    return CONTINUE;
}

MSL_FUNCTION(hunspell_spell)
{
    int r;

    if (*data == '\0')
    {
        strcpy(data, "//echo -sc info * mSLSpell - /hunspell_spell: Insufficient parameters | halt");
        return EXECUTECMD;
    }

    if (!speller)
    {
        strcpy(data, "//echo -sc info * mSLSpell - /hunspell_spell: Hunspell Engine Uninitialized | halt");
        return EXECUTECMD;
    }

    if (resultList)
        speller->free_list(&resultList, resultLen);

    r = speller->spell(data);
    resultLen = speller->suggest(&resultList, data);
    
    sprintf(data, "%d", r);
    return RETURNVAL;
}

MSL_FUNCTION(hunspell_suggest)
{
    char *endptr;
    long n;

    if (*data == '\0')
    {
        strcpy(data, "//echo -sc info * mSLSpell - /hunspell_suggest: Insufficient parameters | halt");
        return EXECUTECMD;
    }

    if (!speller)
    {
        strcpy(data, "//echo -sc info * mSLSpell - /hunspell_spell: Hunspell Engine Uninitialized | halt");
        return EXECUTECMD;
    }

    n = strtol(data, &endptr, 10);
    if (*endptr || n < 0)
    {
        strcpy(data, "//echo -sc info * mSLSpell - /hunspell_spell: Invalid Index Specified | halt");
        return EXECUTECMD;
    }

    if (n == 0)
    {
        sprintf(data, "%d", resultLen);
        return RETURNVAL;
    }

    n -= 1;
    if (n >= resultLen)
    {
        strcpy(data, "");
        return RETURNVAL;
    }

    strcpy(data, resultList[n]);
    return RETURNVAL;
}