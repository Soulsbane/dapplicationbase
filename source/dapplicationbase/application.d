module dapplicationbase.application;

import std.path : buildNormalizedPath;
public import std.stdio;

public import dpathutils.config;
public import ctoptions.getoptmixin;
public import ctoptions.structoptions;

private interface EmptyBase {}
private struct OptionsBase {}

mixin template ApplicationMixin(AppOptions = OptionsBase, InheritedClass = EmptyBase)
{
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
				writeln(ex.msg);
			}
		}

	protected:
		ConfigPath path_;
		StructOptions!AppOptions options_;
	}
}
