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
#include <windows.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
 
#define MSL_FUNCTION(name) \
    int __declspec(dllexport) __stdcall name \
    (HWND mWnd, HWND aWnd, char *data, char *parms, BOOL show, BOOL nopause)
 
enum RETURN_OPERATION
{
    HALT = 0,
    CONTINUE = 1,
    EXECUTECMD = 2,
    RETURNVAL = 3
};
 
 struct LOADINFO
 {
   DWORD  mVersion;
   HWND   mHwnd;
   BOOL   mKeep;
   BOOL   mUnicode;
 };