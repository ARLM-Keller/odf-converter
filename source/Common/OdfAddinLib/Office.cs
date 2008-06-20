/*
 * Copyright (c) 2008, DIaLOGIKa
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of DIaLOGIKa nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY DIaLOGIKa ``AS IS�� AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL DIaLOGIKa BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Runtime.InteropServices;
using System.Runtime.CompilerServices;

namespace OdfConverter
{
    /// <summary>
    /// COM Import and type declarations for Office Interop
    /// </summary>
    namespace Office
    {
        #region MSO Type Declarations
        public enum MsoControlType
        {
            msoControlCustom = 0,
            msoControlButton = 1,
            msoControlEdit = 2,
            msoControlDropdown = 3,
            msoControlComboBox = 4,
            msoControlButtonDropdown = 5,
            msoControlSplitDropdown = 6,
            msoControlOCXDropdown = 7,
            msoControlGenericDropdown = 8,
            msoControlGraphicDropdown = 9,
            msoControlPopup = 10,
            msoControlGraphicPopup = 11,
            msoControlButtonPopup = 12,
            msoControlSplitButtonPopup = 13,
            msoControlSplitButtonMRUPopup = 14,
            msoControlLabel = 15,
            msoControlExpandingGrid = 16,
            msoControlSplitExpandingGrid = 17,
            msoControlGrid = 18,
            msoControlGauge = 19,
            msoControlGraphicCombo = 20,
            msoControlPane = 21,
            msoControlActiveX = 22,
            msoControlSpinner = 23,
            msoControlLabelEx = 24,
            msoControlWorkPane = 25,
            msoControlAutoCompleteCombo = 26,
        }

        public enum MsoAppLanguageID
        {
            msoLanguageIDInstall = 1,
            msoLanguageIDUI = 2,
            msoLanguageIDHelp = 3,
            msoLanguageIDExeMode = 4,
            msoLanguageIDUIPrevious = 5,
        }

        public enum MsoFileDialogType
        {
            msoFileDialogOpen = 1,
            msoFileDialogSaveAs = 2,
            msoFileDialogFilePicker = 3,
            msoFileDialogFolderPicker = 4,
        }

        public enum WdCursorType
        {
            wdCursorWait = 0,
            wdCursorIBeam = 1,
            wdCursorNormal = 2,
            wdCursorNorthwestArrow = 3,
        }

        public enum WdSaveOptions
        {
            wdPromptToSaveChanges = -2,
            wdSaveChanges = -1,
            wdDoNotSaveChanges = 0,
        }

        public enum WdOriginalFormat
        {
            wdWordDocument = 0,
            wdOriginalDocumentFormat = 1,
            wdPromptUser = 2,
        }
        #endregion

        [ComVisible(true), ClassInterface(ClassInterfaceType.None)]
        public sealed class CommandBarButtonEvents : ICommandBarButtonEvents
        {
            private List<CommandBarButtonEvents_ClickEventHandler> _sinks;

            public CommandBarButtonEvents()
            {
                _sinks = new List<CommandBarButtonEvents_ClickEventHandler>();
            }

            public void Click(object ctrl, ref bool cancelDefault)
            {
                foreach (CommandBarButtonEvents_ClickEventHandler sink in _sinks)
                {
                    sink.Invoke(ctrl, cancelDefault);
                }
            }

            public void Register(CommandBarButtonEvents_ClickEventHandler sink)
            {
                _sinks.Add(sink);
            }
        }

        [ComImport, Guid("000C0351-0000-0000-C000-000000000046"),
        InterfaceType(ComInterfaceType.InterfaceIsIDispatch)]
        public interface ICommandBarButtonEvents
        {
            [DispId(1)]
            void Click([In, MarshalAs(UnmanagedType.Interface)] object ctrl, [In, Out] ref bool cancelDefault);
        }

        #region Ribbon
        [ComImport, Guid("000C0396-0000-0000-C000-000000000046"), TypeLibType((short)0x1040)]
        public interface IRibbonExtensibility
        {
            [return: MarshalAs(UnmanagedType.BStr)]
            [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime), DispId(1)]
            string GetCustomUI([In, MarshalAs(UnmanagedType.BStr)] string RibbonID);

        }

        [ComImport, Guid("000C0395-0000-0000-C000-000000000046"), TypeLibType((short)0x1040)]
        public interface IRibbonControl
        {
            [DispId(1)]
            string Id { [return: MarshalAs(UnmanagedType.BStr)] [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime), DispId(1)] get; }
        }
        #endregion

        public delegate void CommandBarButtonEvents_ClickEventHandler(object Ctrl, object CancelDefault);
    }

    namespace Extensibility
    {
        [ComImport, Guid("B65AD801-ABAF-11D0-BB8B-00A0C90F2744"), TypeLibType((short)0x1040)]
        public interface IDTExtensibility2
        {
            [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime), DispId(1)]
            void OnConnection([In, MarshalAs(UnmanagedType.IDispatch)] object Application, [In] ext_ConnectMode ConnectMode, [In, MarshalAs(UnmanagedType.IDispatch)] object AddInInst, [In, MarshalAs(UnmanagedType.SafeArray, SafeArraySubType = VarEnum.VT_VARIANT)] ref Array custom);
            [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime), DispId(2)]
            void OnDisconnection([In] ext_DisconnectMode RemoveMode, [In, MarshalAs(UnmanagedType.SafeArray, SafeArraySubType = VarEnum.VT_VARIANT)] ref Array custom);
            [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime), DispId(3)]
            void OnAddInsUpdate([In, MarshalAs(UnmanagedType.SafeArray, SafeArraySubType = VarEnum.VT_VARIANT)] ref Array custom);
            [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime), DispId(4)]
            void OnStartupComplete([In, MarshalAs(UnmanagedType.SafeArray, SafeArraySubType = VarEnum.VT_VARIANT)] ref Array custom);
            [MethodImpl(MethodImplOptions.InternalCall, MethodCodeType = MethodCodeType.Runtime), DispId(5)]
            void OnBeginShutdown([In, MarshalAs(UnmanagedType.SafeArray, SafeArraySubType = VarEnum.VT_VARIANT)] ref Array custom);
        }

        [Guid("289E9AF1-4973-11D1-AE81-00A0C90F26F4")]
        public enum ext_ConnectMode
        {
            ext_cm_AfterStartup = 0,
            ext_cm_Startup = 1,
            ext_cm_External = 2,
            ext_cm_CommandLine = 3,
            ext_cm_Solution = 4,
            ext_cm_UISetup = 5,
        }
        
        [Guid("289E9AF2-4973-11D1-AE81-00A0C90F26F4")]
        public enum ext_DisconnectMode
        {
            ext_dm_HostShutdown = 0,
            ext_dm_UserClosed = 1,
            ext_dm_UISetupComplete = 2,
            ext_dm_SolutionClosed = 3,
        }
    }
}
