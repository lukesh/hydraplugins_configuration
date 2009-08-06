package com.hydraframework.plugins.configuration.controller {
	import com.hydraframework.core.mvc.events.Notification;
	import com.hydraframework.core.mvc.interfaces.IFacade;
	import com.hydraframework.core.mvc.patterns.command.SimpleCommand;
	import com.hydraframework.plugins.configuration.ConfigurationManager;

	public class ConfigureCommand extends SimpleCommand {

		public function get plugin():ConfigurationManager {
			return ConfigurationManager(this.facade.retrievePlugin(ConfigurationManager.NAME));
		}

		public function ConfigureCommand(facade:IFacade) {
			super(facade);
		}

		override public function execute(notification:Notification):void {
			if (notification.isRequest()) {
				plugin.configure();
			}
		}
	}
}