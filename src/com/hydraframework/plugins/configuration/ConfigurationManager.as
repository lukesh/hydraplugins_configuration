/*
   HydraFramework - Copyright (c) 2009 andCulture, Inc. Some rights reserved.
   Your reuse is governed by the Creative Commons Attribution 3.0 United States License
 */
package com.hydraframework.plugins.configuration {
	import com.hydraframework.core.mvc.events.Notification;
	import com.hydraframework.core.mvc.events.Phase;
	import com.hydraframework.core.mvc.patterns.plugin.Plugin;
	import com.hydraframework.plugins.configuration.controller.ConfigureCommand;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class ConfigurationManager extends Plugin {
		public static const NAME:String = "ConfigurationManager";
		public static const CONFIGURE:String = "plugins.configuration.configure";
		public static const CONFIGURATION_COMPLETE:String = "plugins.configuration.configurationComplete";
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		private var configList:Array;
		private var configPointer:int;
		private var loader:URLLoader;
		/**
		 * Returns a loosely-typed configuration object populated from the loaded
		 * xml file.
		 */
		private var _configuration:Object;

		public function get configuration():Object {
			return _configuration;
		}
		
		public static function get configuration():Object {
			return ConfigurationManager.instance.configuration;
		} 
		
		/**
		 * @private
		 * Cached instance of the ConfigurationManager.
		 */
		private static const _instance:ConfigurationManager = new ConfigurationManager();

		/**
		 * Returns a cached instance of the ConfigurationManager.
		 */
		public static function getInstance():ConfigurationManager {
			return _instance;
		}
		
		public static function get instance():ConfigurationManager {
			return _instance;
		}

		public function ConfigurationManager() {
			super(NAME);
			initObjects();
			initEvents();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Public Methods
		//
		//--------------------------------------------------------------------------
		
		override public function initialize():void {
			super.initialize();
		}
		
		override public function preinitialize():void {
			super.preinitialize();
			this.facade.registerCommand(ConfigurationManager.CONFIGURE, ConfigureCommand);
		}

		/**
		 * Retrieves an external XML configuration file located in the application's build directory
		 * that contains various parameters pertaining to the application.
		 *
		 * @see handleXMLDataLoaded
		 */
		public function configure():void {
			configPointer = 0;
			_configuration = {};
			loadNextConfigFile();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Private Methods
		//
		//--------------------------------------------------------------------------
		/**
		 * @private
		 */
		private function loadNextConfigFile():void {
			if (configPointer < configList.length) {
				loader.load(new URLRequest(configList[configPointer]));
			} else {
				this.sendNotification(new Notification(ConfigurationManager.CONFIGURE, null, Phase.CANCEL, true));
			}
		}

		/**
		 * @private
		 */
		private function initObjects():void {
			loader = new URLLoader();
			configPointer = 0;
			configList = ["config.xml", "config.local.xml"];
		}

		/**
		 * @private
		 */
		private function initEvents():void {
			loader.addEventListener(Event.COMPLETE, handleXMLDataLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, handleXMLDataIOError);
		}
		
		/**
		 * @private
		 * Parses a string value and returns the correct primitive.
		 */
		private function parseValue(value:String):* {
			if(value.toLowerCase() == "true") {
				return true;
			} else if(value.toLowerCase() == "false") {
				return false;
			}
			return value;
		}

		//--------------------------------------------------------------------------
		//
		//  Events
		//
		//--------------------------------------------------------------------------
		/**
		 * @private
		 * Called upon successful load of the configuration file.
		 *
		 * @param event Event object being sent from URLLoader.
		 */
		private function handleXMLDataLoaded(event:Event):void {
			var result:XMLList = new XMLList(event.target.data);
			for each(var node:XML in result.children()) {
				this.configuration[node.name().toString()] = parseValue(node.toString());
			}
			configPointer++;
			if (configPointer < configList.length) {
				loadNextConfigFile();
			} else {
				this.sendNotification(new Notification(ConfigurationManager.CONFIGURE, this.configuration, Phase.RESPONSE, true));
				this.sendNotification(new Notification(ConfigurationManager.CONFIGURATION_COMPLETE, this.configuration, Phase.RESPONSE, true));
				loader.removeEventListener(Event.COMPLETE, handleXMLDataLoaded);
				loader = null;
			}
		}

		private function handleXMLDataIOError(event:IOErrorEvent):void {
			configPointer++;
			loadNextConfigFile();
		}
	}
}