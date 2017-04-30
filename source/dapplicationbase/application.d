module dapplicationbase.application;

private interface EmptyBase {}
private struct OptionsBase {}

mixin template ApplicationMixin(AppOptions = OptionsBase, InheritedClass = EmptyBase)
{
	import dpathutils.config;
	import ctoptions.getoptmixin;
	import ctoptions.structoptions;
	import std.path : buildNormalizedPath;

	class Application : InheritedClass
	{
	public:
		this(const string organizationName, const string applicationName) @safe
		{
			path_.create(organizationName, applicationName);
		}

		void create(string[] arguments)
		{
			createConfigDirs("config");
			loadOptions();
			handleCmdLineArguments(arguments);
		}

		void createConfigDirs(T...)(T dirs)
		{
			foreach(dir; dirs)
			{
				path_.createDir(dir);
			}
		}

		void loadOptions()
		{
			immutable string fileName = buildNormalizedPath(path_.getDir("config"), "app.config");

			options_.createDefaultFile(fileName);
			options_.loadFile(fileName);
		}

		void handleCmdLineArguments(string[] arguments)
		{
			try
			{
				generateGetOptCode!AppOptions(arguments, options_);
			}
			catch(GetOptMixinException ex)
			{
				throw new GetOptMixinException(ex.msg);
			}
		}

	protected:
		ConfigPath path_;
		StructOptions!AppOptions options_;
	}
}
