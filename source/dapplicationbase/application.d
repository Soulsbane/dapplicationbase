module dapplicationbase.application;


private interface EmptyBase {}
private struct OptionsBase {}

mixin template ApplicationMixin(AppOptions = OptionsBase, InheritedClass = EmptyBase)
{
	import dpathutils.config;
	import ctoptions.getoptmixin;
	import ctoptions.structoptions;

	class Application : InheritedClass
	{
		this(const string organizationName, const string applicationName) @safe
		{
			path_.create(organizationName, applicationName);
		}

		void create(string[] arguments)
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
