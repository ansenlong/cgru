#include "afcommon.h"
#include "jobcontainer.h"
#include "rendercontainer.h"
#include "threadargs.h"
#include "usercontainer.h"

#define AFOUTPUT
#undef AFOUTPUT
#include "../include/macrooutput.h"

af::Msg * threadProcessJSON( ThreadArgs * i_args, af::Msg * i_msg)
{
	rapidjson::Document document;
	std::string error;
	char * data = af::jsonParseMsg( document, i_msg, &error);
	if( data == NULL )
	{
		AFCommon::QueueLogError( error);
		delete i_msg;
		return NULL;
	}

    af::Msg * o_msg_response = NULL;

	if( document.HasMember("job"))
	{
		// No containers locks needed here.
		// Job registration is a complex procedure.
		// It locks and unlocks needed containers itself.
		i_args->jobs->job_register( new JobAf( document["job"]), i_args->users, i_args->monitors);
	}

	JSON & getObj = document["get"];
	if( getObj.IsObject())
	{
		std::string type, mode;
		af::jr_string("type", type, getObj);
		af::jr_string("mode", mode, getObj);
		bool full = false;
		if( mode == "full")
			full = true;

		std::vector<int32_t> ids;
		af::jr_int32vec("ids", ids, getObj);

		std::string mask;
		af::jr_string("mask", mask, getObj);

		if( type == "jobs" )
		{
			std::vector<int32_t> uids;
			af::jr_int32vec("uids", uids, getObj);
			if( uids.size())
			{
				AfContainerLock jLock( i_args->jobs,  AfContainerLock::READLOCK);
				AfContainerLock uLock( i_args->users, AfContainerLock::READLOCK);
				o_msg_response = i_args->users->generateJobsList( uids, type, true);
			}
			else
			{
				AfContainerLock lock( i_args->jobs, AfContainerLock::READLOCK);
				o_msg_response = i_args->jobs->generateList(
					full ? af::Msg::TJob : af::Msg::TJobsList, type, ids, mask, true);
			}
		}
		else if( type == "users")
		{
			AfContainerLock lock( i_args->users, AfContainerLock::READLOCK);
			o_msg_response = i_args->users->generateList( af::Msg::TUsersList, type, ids, mask, true);
		}
		else if( type == "renders")
		{
			AfContainerLock lock( i_args->renders, AfContainerLock::READLOCK);
			o_msg_response = i_args->renders->generateList( af::Msg::TRendersList, type, ids, mask, true);
		}
	}

	if( document.HasMember("action"))
	{
		i_args->msgQueue->pushMsg( i_msg);
		delete [] data;
		return NULL;
	}

	delete [] data;
	delete i_msg;

	return o_msg_response;
}