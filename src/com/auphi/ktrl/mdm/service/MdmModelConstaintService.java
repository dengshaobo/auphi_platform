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
package com.auphi.ktrl.mdm.service;



import java.sql.SQLException;
import java.util.Map;

import com.auphi.data.hub.core.PaginationSupport;
import com.auphi.data.hub.core.struct.Dto;

import com.auphi.ktrl.mdm.domain.MdmModelConstaint;



public interface MdmModelConstaintService {
	
	public PaginationSupport<MdmModelConstaint> query(Dto dto)throws SQLException;
	
	public Integer queryMaxId(Dto dto);
	
	public void save(MdmModelConstaint object);
	
	public void update(MdmModelConstaint object);
	
	public void delete(Map<String, Object> object);
	
	public void deleteByIdAttribute(Map<String, Object> object);
}
