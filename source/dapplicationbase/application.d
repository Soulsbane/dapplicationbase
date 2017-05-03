module dapplicationbase.application;

public import std.path : buildNormalizedPath;
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
		void create(const string organizationName, const string applicationName)
		{
			path_.create(organizationName, applicationName);
			createConfigDirs("config");
			loadOptions();
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
			gen = new GetOptCodeGenerator!(AppOptions);
			gen.generate(arguments, options_);
		}

	protected:
		ConfigPath path_;
		StructOptions!AppOptions options_;
		GetOptCodeGenerator!(AppOptions) gen;
	}
}
