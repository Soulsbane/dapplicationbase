module dapplicationbase.settings;

public import ctoptions.structoptions;
public import dpathutils.config;

struct Settings(T)
{
	auto opDispatch(string name, Args...)(Args args)
	{
		static if(__traits(hasMember, path_, name))
		{
			return __traits(getMember, path_, name)(args);
		}

		static if(__traits(hasMember, options_, name))
		{
			return __traits(getMember, options_, name)(args);
		}
	}

	alias Options = options_;
	alias Path = path_;

	StructOptions!T options_;
	ConfigPath path_;
}
