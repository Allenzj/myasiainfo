package freemarker.core;

import freemarker.template.TemplateException;
import freemarker.template.TemplateModel;

public class ExtBuildIn extends BuiltIn{
	
	private ExtBuildInModel model;
	
	public ExtBuildIn(ExtBuildInModel model){
		this.model = model;
		register(this.model);
	}
	
	String getName(){
		return model.getName();
	}
	
	TemplateModel _eval(Environment env) throws TemplateException {
		return model.calculateResult(target.evalAndCoerceToString(env), env);
	}

	public abstract static class ExtBuildInModel {
		public abstract String getName();
		public abstract TemplateModel calculateResult(String s, Environment env)throws TemplateException;
	}
	
	public void register(ExtBuildInModel extBuildInModel){
		BuiltIn.builtins.put(extBuildInModel.getName(), this);
	}
}
