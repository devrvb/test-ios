//
// Copyright (c) 2010, �㽭�󻪼����ɷ����޹�˾
// All righSC reserved.
// 
// �� �� ����StreamConvertor.h
// ժ    Ҫ���ṩSC����װ��֧��DHAV����
//
// �޶���¼������
// ������ڣ�2011��01��06��
// ��    �ߣ�
//

#ifndef _STREAM_CONVERTOR__H
#define _STREAM_CONVERTOR__H

#define IN
#define OUT

#if (defined(WIN32) || defined(WIN64))
    #ifdef ST_EXPORTS_DLL
        #define SCAPI __declspec(dllexport)
    #elif defined ST_USE_DLL
        #define SCAPI __declspec(dllimport)
	#else
		#define SCAPI 
    #endif

    #define CALLMETHOD __stdcall

#else /*linux or mac*/

    #define SCAPI
    #define CALLMETHOD

#endif


#ifdef __cplusplus
extern "C" {
#endif

typedef void* SCHANDLE;

// ������
enum
{
	SCERR_NoError = 0,				// �ɹ�
	SCERR_InvalidHandle,			// ��Ч���
	SCERR_NoSupport,				// �������װ���Ͳ�֧��
	SCERR_Thread,					// �ڲ��̳߳���
	SCERR_Param,					// ��������

	SCERR_FileOpen,					// �ļ��򿪳��������ѱ������
	SCERR_FileRead,					// �ļ���ȡ����
	SCERR_FileWrite,				// �ļ�д�����
	SCERR_Format,					// ������ʽ�����޷���������

	SCERR_BufferOverFlow,			// �ڲ��������
	SCERR_SysOutOfMem,				// ϵͳ�ڴ治��

	SCERR_NoIDRFrame,				// �������װ���Ͳ�֧��
	SCERR_NoOutPut,					// ͬ����װ������߼������������
	SCERR_ErrorOrder				// ����˳������
};

typedef enum _SC_TYPE
{
	SC_MOV64 = 19,
}SC_TYPE;

//
// ��  �ܣ���һ��SCת����ʽ���������ļ�����
// ��  ����
//		   IN  eSCType��ת������
//		   IN  szFileName Ҫ������ļ���
//			IN nlen   �ļ�������
//		   OUT pSCHandle��SC��ת��ͨ�����
//
// ����ֵ����������
//
SCAPI int CALLMETHOD SC_OpenFile(IN SC_TYPE eSCType, IN const char* szFileName,IN int nlen, OUT SCHANDLE* pSCHandle);

//
// ��  �ܣ���ԭʼ��������SC��ת����
// ��  ����
//		   IN hSCHandle��SC��ת��ͨ������SC_OpenFile����
//		   IN pData��ԭʼ����
//		   IN iLen��ԭʼ���ݳ���
//
// ����ֵ����������
//
SCAPI int CALLMETHOD SC_InputData(IN SCHANDLE hSCHandle, IN unsigned char* pData, IN int iLen);



//
// ��  �ܣ���ʾת���������ݽ���
// ��  ����
//		   IN hSCHandle��SC��ת��ͨ������SC_OpenFile����,(mp4�������)
//
// ����ֵ����������
//
SCAPI int CALLMETHOD SC_EndInput(IN SCHANDLE hSCHandle);

//
// ��  �ܣ��ر�SC��ת��ͨ��
// ��  ����
//		   IN hSCHandle��SC��ת��ͨ������SC_Open����
// ����ֵ����������
//
SCAPI int CALLMETHOD SC_Close(IN SCHANDLE hSCHandle);




#ifdef __cplusplus
}
#endif

#endif