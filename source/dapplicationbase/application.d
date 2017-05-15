module dapplicationbase.application;

public import std.path : buildNormalizedPath;
public import std.stdio;

public import dpathutils.config;
public import ctoptions.getoptmixin;
public import ctoptions.structoptions;
public import std.getopt;

private interface EmptyBase {}
private struct OptionsBase {}

mixin template ApplicationMixin(AppOptions = OptionsBase, InheritedClass = EmptyBase)
{
	class Application : InheritedClass
	{
	public:
		this()
		{
			// We have to jump through a bunch of hoops here since D doesn't support multiple inheritance.
			this.getOptGen_ = new GetOptCodeGenerator!(AppOptions);

			this.getOptGen_.setCallback!"onNoArguments"(&onNoArguments);
			this.getOptGen_.setCallback!"onHelp"(&onHelp);
			this.getOptGen_.setCallback!"onValidArguments"(&onValidArguments);
			this.getOptGen_.setCallback!"onUnknownArgument"(&onUnknownArgument);
			this.getOptGen_.setCallback!"onInvalidArgument"(&onInvalidArgument);
		}

		// We have to reimplement these callbacks since alias this doesn't support override of a member function
		// in the inherited class.
		void onNoArguments() {}

		void onHelp(Option[] options)
		{
			defaultGetoptPrinter("The following options are available:", options);
		}

		void onValidArguments() {}

		void onUnknownArgument(const string msg)
		{
			writeln(msg, ". For a list of available commands use --help.");
		}

		void onInvalidArgument(const string msg)
		{
			writeln("Invalid Argument!");
			writeln(msg);
		}

		void create(const string organizationName, const string applicationName)
		{
			path_.create(organizationName, applicationName);
			createConfigDirs("config");
			loadOptions();
		}

		void createConfigDirs(T...)(T dirs)
		{
			path_.createDir(dirs);
		}

		void loadOptions()
		{
			immutable string fileName = buildNormalizedPath(path_.getDir("config"), "app.config");

			options_.createDefaultFile(fileName);
			options_.loadFile(fileName);
		}

		void handleCmdLineArguments(string[] arguments)
		{
			getOptGen_.generate(arguments, options_);
		}

	protected:
		ConfigPath path_;
		StructOptions!AppOptions options_;
		GetOptCodeGenerator!(AppOptions) getOptGen_;
		alias getOptGen_ this;
	}
}
