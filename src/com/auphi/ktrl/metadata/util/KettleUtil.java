/*******************************************************************************
 *
 * Auphi Data Integration PlatformKettle Platform
 * Copyright C 2011-2017 by Auphi BI : http://www.doetl.com 

 * Support：support@pentahochina.com
 *
 *******************************************************************************
 *
 * Licensed under the LGPL License, Version 3.0 the "License";
 * you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 *    https://opensource.org/licenses/LGPL-3.0 

 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 ******************************************************************************/
package com.auphi.ktrl.metadata.util;

import java.sql.Connection;
import java.util.List;

import com.auphi.ktrl.metadata.bean.MetaDataConnBean;
import com.auphi.ktrl.util.ClassLoaderUtil;

public interface KettleUtil {
	

	public Object[] getJobTransTree(MetaDataConnBean connBean,ClassLoaderUtil classLoaderUtil,String userName,String password);
	
	public boolean createAutoDoc(String fileDir,String fileName,String fileType,
			 String outPutTypeStr,String targetFilename,
			 MetaDataConnBean connBean,String userName,String password,ClassLoaderUtil classLoaderUtil);
}
