.//============================================================================
.// This is the root archetype for generation.
.//============================================================================
.//
.//
.print "starting ${info.date}"
.invoke r = GET_ENV_VAR( "ROX_MC_ARC_DIR" )
.assign arc_path = r.result
.if ( "" == arc_path )
  .print "\nERROR:  Environment variable ROX_MC_ARC_DIR not set."
  .exit 100
.end if
.//
.select any s_dt from instances of S_DT
.if ( empty s_dt )
  .print "No data found.  The exported model file appears to be empty."
  .exit 100
.end if
.//
.include "${arc_path}/frag_util.arc"
.include "${arc_path}/m.bridge.arc"
.include "${arc_path}/m.component.arc"
.include "${arc_path}/m.datatype.arc"
.include "${arc_path}/m.domain.arc"
.include "${arc_path}/m.event.arc"
.include "${arc_path}/m.class.arc"
.include "${arc_path}/m.system.arc"
.include "${arc_path}/q.class.arc"
.include "${arc_path}/q.class.cdispatch.arc"
.include "${arc_path}/q.class.events.arc"
.include "${arc_path}/q.class.factory.arc"
.include "${arc_path}/q.class.instance.dumper.arc"
.include "${arc_path}/q.class.link.arc"
.include "${arc_path}/q.class.pei.arc"
.include "${arc_path}/q.class.persist.arc"
.include "${arc_path}/q.class.poly.arc"
.include "${arc_path}/q.class.sem.arc"
.include "${arc_path}/q.class.where.arc"
.include "${arc_path}/q.component.arc"
.include "${arc_path}/q.datatype.arc"
.include "${arc_path}/q.domain.analyze.arc"
.include "${arc_path}/q.domain.bridge.arc"
.include "${arc_path}/q.domain.classes.arc"
.include "${arc_path}/q.domain.datatype.arc"
.include "${arc_path}/q.domain.limits.arc"
.include "${arc_path}/q.domain.sync.arc"
.include "${arc_path}/q.main.arc"
.include "${arc_path}/q.names.arc"
.include "${arc_path}/q.r_rel.arc"
.include "${arc_path}/q.oal.act_blk.arc"
.include "${arc_path}/q.oal.action.arc"
.include "${arc_path}/q.oal.analyze.arc"
.include "${arc_path}/q.oal.utils.arc"
.include "${arc_path}/q.oal.translate.arc"
.include "${arc_path}/q.oal.test.arc"
.include "${arc_path}/q.parameters.arc"
.include "${arc_path}/q.parm.sort.arc"
.include "${arc_path}/q.rel.pseudoformalize.arc"
.include "${arc_path}/q.smt.generate.arc"
.include "${arc_path}/q.sys.populate.arc"
.include "${arc_path}/q.sys.singletons.arc"
.include "${arc_path}/q.utils.arc"
.include "${arc_path}/q.val.translate.arc"
.include "${arc_path}/sys_util.arc"
.include "${arc_path}/t.smt.c"
.include "${arc_path}/t.component.message.body.c"
.//
.select any te_file from instances of TE_FILE
.if ( empty te_file )
  .invoke mc_main( arc_path )
  .select any te_file from instances of TE_FILE
  .// Uncomment the following lines to create an instance dumper archetype.
  .//.invoke r = TE_CLASS_instance_dumper()
  .//${r.body}
  .//.emit to file "../../src/q.class.instance.dump.arc"
  .//.include "${te_file.arc_path}/schema_gen.arc"
  .//.exit 507
  .//.print "dumping instances ${info.date}"
  .//.include "${te_file.arc_path}/q.class.instance.dump.arc"
.else
  .assign te_file.arc_path = arc_path
.end if
.// 8) Include system level user defined archetype functions.
.include "${te_file.system_color_path}/${te_file.system_functions_mark}"
.print "System level marking complete."
.//
.select any te_sys from instances of TE_SYS
.// Pull into scope global values from singleton classes.
.select any te_callout from instances of TE_CALLOUT
.select any te_container from instances of TE_CONTAINER
.select any te_copyright from instances of TE_COPYRIGHT
.select any te_dlist from instances of TE_DLIST
.select any te_dma from instances of TE_DMA
.select any te_eq from instances of TE_EQ
.select any te_extent from instances of TE_EXTENT
.select any te_file from instances of TE_FILE
.assign te_file.arc_path = arc_path
.select any te_ilb from instances of TE_ILB
.select any te_instance from instances of TE_INSTANCE
.select any te_persist from instances of TE_PERSIST
.select any te_prefix from instances of TE_PREFIX
.select any te_set from instances of TE_SET
.select any te_slist from instances of TE_SLIST
.select any te_string from instances of TE_STRING
.select any te_target from instances of TE_TARGET
.select any te_thread from instances of TE_THREAD
.select any te_tim from instances of TE_TIM
.select any te_trace from instances of TE_TRACE
.select any te_typemap from instances of TE_TYPEMAP
.//
.select many active_te_cs from instances of TE_C where ( ( selected.internal_behavior ) and ( selected.included_in_build ) )
.invoke r = TE_C_sort( active_te_cs )
.assign first_te_c = r.result
.assign num_ooa_doms = cardinality active_te_cs
.invoke SetSystemSelfEventQueueParameters( active_te_cs )
.invoke SetSystemNonSelfEventQueueParameters( active_te_cs )
.invoke r = RenderSystemLimitsDeclarations( active_te_cs )
.assign system_parameters = r.body
.invoke system_class_array = DefineClassInfoArray( first_te_c )
.//
.select many te_ees from instances of TE_EE where ( ( ( selected.RegisteredName != "TIM" ) and ( selected.te_cID == 0 ) ) and ( selected.Included ) )
.if ( not_empty te_ees )
  .select any te_c from instances of TE_C where ( false )
  .include "${te_file.arc_path}/q.domain.bridges.arc"
.end if
.select many te_cs from instances of TE_C where ( selected.included_in_build )
.for each te_c in te_cs
  .select many te_ees related by te_c->TE_EE[R2085] where ( ( selected.RegisteredName != "TIM" ) and ( selected.Included ) )
  .include "${te_file.arc_path}/q.domain.bridges.arc"
  .include "${te_file.arc_path}/q.classes.arc"
.end for
.//
.select any tim_te_ee from instances of TE_EE where ( ( selected.RegisteredName == "TIM" ) and ( selected.Included ) )
.assign TLM_message_order = ""
.// Generate interface declarations.
.include "${te_file.arc_path}/q.component.interfaces.arc"
.// Generate components.
.include "${te_file.arc_path}/q.components.arc"
.// Generate system packages.
.include "${te_file.arc_path}/q.packages.arc"
.//
.//
.//============================================================================
.// Generate the system code.
.//============================================================================
.invoke main_decl = GetMainTaskEntryDeclaration()
.invoke r = GetMainTaskEntryReturn()
.assign return_body = r.body
.select any te_cia from instances of TE_CIA
.//
.// function-based archetype generation
.//
.invoke event_prioritization_needed = GetSystemEventPrioritizationNeeded()
.invoke non_self_event_queue_needed = GetSystemNonSelfEventQueueNeeded()
.invoke self_event_queue_needed = GetSystemSelfEventQueueNeeded()
.//
.assign printf = "printf"
.if ( te_thread.flavor == "Nucleus" )
  .assign printf = "NU_printf"
.end if
.assign inst_id_in_handle = ""
.//
.invoke persist_check_mark = GetPersistentCheckMarkPostName()
.//
.assign all_domain_include_files = ""
.assign all_instance_loaders = ""
.assign all_batch_relaters = ""
.assign all_instance_dumpersd = ""
.assign all_instance_dumpers = ""
.assign all_max_class_numbers = "0"
.select many te_cs from instances of TE_C where ( selected.included_in_build )
.for each te_c in te_cs
  .if ( te_c.internal_behavior )
    .select one te_dci related by te_c->TE_DCI[R2090]
    .assign all_domain_include_files = all_domain_include_files + "#include ""${te_c.classes_file}.${te_file.hdr_file_ext}""\n"
    .assign all_instance_loaders = all_instance_loaders + "  ${te_c.Name}_instance_loaders,\n"
    .assign all_batch_relaters = all_batch_relaters + "  ${te_c.Name}_batch_relaters,\n"
    .assign all_instance_dumpersd = all_instance_dumpersd + "extern ${te_prefix.result}idf ${te_c.Name}_instance_dumpers[ ${te_dci.max} ];\n"
    .assign all_instance_dumpers = all_instance_dumpers + "  ${te_c.Name}_instance_dumpers,\n"
    .assign all_max_class_numbers = ( all_max_class_numbers + " + " ) + te_dci.max
  .end if
.end for
.//
.//
.//
.// template-based generation
.//
.//
.//
.//=============================================================================
.// Generate main.
.//=============================================================================
.assign sysc_top_includes = ""
.assign sysc_top_inst_decls = ""
.assign sysc_top_insts = ""
.assign sysc_top_insts_cleanup = ""
.assign gen_vista_top_template = false
.select many tm_build_pkgs from instances of TM_BUILD
.for each tm_build_pkg in tm_build_pkgs
  .assign build_pkg_name = "$r{tm_build_pkg.package_obj_name}"
  .assign sysc_top_includes = "${sysc_top_includes}" + "#include ""${build_pkg_name}.${te_file.hdr_file_ext}""\n"
  .assign sysc_top_inst_decls = "${sysc_top_inst_decls}" + "${build_pkg_name}* $r{tm_build_pkg.package_inst_name} = 0;\n"
  .assign sysc_top_insts = "${sysc_top_insts}" + "  $r{tm_build_pkg.package_inst_name} = new ${build_pkg_name}( ""${build_pkg_name}"" );\n"
  .assign sysc_top_insts_cleanup = "delete $r{tm_build_pkg.package_inst_name};\n"
  .if ( te_sys.SystemCPortsType == "BitLevelSignals" )
    .assign sysc_top_insts = "${sysc_top_insts}" + "  $r{tm_build_pkg.package_inst_name}->clk(clk);\n"
    .assign sysc_top_insts = "${sysc_top_insts}" + "  $r{tm_build_pkg.package_inst_name}->rst_X(rst_X);\n"
  .end if
.end for
.invoke class_dispatch_array = GetDomainDispatcherTableName( "" )
.assign num_ooa_doms = cardinality active_te_cs
.assign dq_arg_type = "void"
.assign dq_arg = ""
.assign thread_number = ""
.if ( te_thread.enabled )
  .assign dq_arg_type = "const u1_t"
  .assign dq_arg = "t "
  .assign thread_number = "t"
.end if
.include "${te_file.arc_path}/t.sysc_main.c"
.emit to file "${te_file.system_source_path}/${te_file.sys_main}.${te_file.src_file_ext}"
.if ( te_sys.SystemCPortsType == "TLM" )
  .assign gen_vista_top_template = true
  .include "${te_file.arc_path}/t.sysc_main.c"
  .emit to file "${te_file.system_source_path}/sysc_main_template.${te_file.src_file_ext}"
.end if
.//
.invoke r = DefineActiveClassCountArray( te_cs )
.assign active_class_counts = r.body
.assign domain_num_var = "domain_num"
.if ( te_sys.PersistentClassCount > 0 )
  .invoke r = PersistentClassUnion( active_te_cs )
  .assign persist_class_union = r.result
  .invoke persist_post_link = GetPersistentPostLinkName()
  .assign inst_id_in_handle = "  ${te_persist.dirty_type} ${te_persist.dirty_name};\n"
  .include "${te_file.arc_path}/t.sys_persist.c"
  .emit to file "${te_file.system_source_path}/${te_file.persist}.${te_file.src_file_ext}"
  .//
  .include "${te_file.arc_path}/t.sys_persist.h"
  .emit to file "${te_file.system_include_path}/${te_file.persist}.${te_file.hdr_file_ext}"
  .//
  .include "${te_file.arc_path}/t.sys_nvs.h"
  .emit to file "${te_file.system_include_path}/${te_file.nvs}.${te_file.hdr_file_ext}"
  .//
  .include "${te_file.arc_path}/t.sys_nvs.c"
  .emit to file "${te_file.system_include_path}/${te_file.nvs}.${te_file.src_file_ext}"
.end if
.//
.if ( te_thread.enabled )
  .// System-C provides its own threading.
  .if ( te_thread.flavor == "POSIX" )
    .include "${te_file.arc_path}/t.sys_threadposix.c"
  .elif ( te_thread.flavor == "Nucleus" )
    .include "${te_file.arc_path}/t.sys_threadnuke.c"
  .elif ( te_thread.flavor == "Windows" )
    .include "${te_file.arc_path}/t.sys_threadwin.c"
  .elif ( te_thread.flavor == "OSX" )
    .include "${te_file.arc_path}/t.sys_threadosx.c"
  .elif ( te_thread.flavor == "AUTOSAR" )
    .include "${te_file.arc_path}/t.sys_threadautosar.c"
  .end if
  .emit to file "${te_file.system_source_path}/${te_file.thread}.${te_file.src_file_ext}"
.end if
.//
.if ( te_sys.MaxInterleavedBridges > 0 )
  .invoke disable_interrupts = UserDisableInterrupts()
  .invoke enable_interrupts = UserEnableInterrupts()
  .//===========================================================================
  .// Generate sys_ilb.h into system gen includes.
  .//===========================================================================
  .include "${te_file.arc_path}/t.sys_ilb.h"
  .emit to file "${te_file.system_include_path}/${te_file.ilb}.${te_file.hdr_file_ext}"
  .//
  .//===========================================================================
  .// Generate sys_ilb.c into system gen source.
  .//===========================================================================
  .include "${te_file.arc_path}/t.sys_ilb.c"
  .emit to file "${te_file.system_source_path}/${te_file.ilb}.${te_file.src_file_ext}"
.end if
.//
.//=============================================================================
.// Generate sys_factory.h into system gen includes.
.//=============================================================================
.include "${te_file.arc_path}/t.sys_factory.h"
.emit to file "${te_file.system_include_path}/${te_file.factory}.${te_file.hdr_file_ext}"
.//
.if ( not_empty te_cs )
.//=============================================================================
.// Generate sys_factory.c into system gen source.
.//=============================================================================
.include "${te_file.arc_path}/t.sys_factory.c"
.emit to file "${te_file.system_source_path}/${te_file.factory}.${te_file.src_file_ext}"
.end if
.//
.//=============================================================================
.// Generate sys_types.h containing the system-level declared types as well as
.// types from other systems used via inter-project references.
.//=============================================================================
.select many s_syss from instances of S_SYS
.select many ep_pkgs related by s_syss->EP_PKG[R1401]
.select many nested_ep_pkgs related by ep_pkgs->PE_PE[R8000]->EP_PKG[R8001]
.select many triply_nested_ep_pkgs related by nested_ep_pkgs->PE_PE[R8000]->EP_PKG[R8001]
.assign ep_pkgs = ep_pkgs | nested_ep_pkgs
.assign ep_pkgs = ep_pkgs | triply_nested_ep_pkgs
.select many enumeration_te_dts related by ep_pkgs->PE_PE[R8000]->S_DT[R8001]->S_EDT[R17]->S_DT[R17]->TE_DT[R2021]
.for each te_dt in enumeration_te_dts
  .invoke r = TE_DT_EnumerationDataTypes( te_dt )
  .assign te_typemap.enumeration_info = te_typemap.enumeration_info + r.body
.end for
.select many structured_te_dts related by ep_pkgs->PE_PE[R8000]->S_DT[R8001]->S_SDT[R17]->S_DT[R17]->TE_DT[R2021]
.invoke s = TE_DT_StructuredDataTypes( structured_te_dts )
.assign te_typemap.structured_data_types = te_typemap.structured_data_types + s.body
.// Get all components, not just those with internal behavior.
.select many te_cs from instances of TE_C where ( selected.included_in_build )
.invoke r = UserSuppliedDataTypeIncludes()
.assign te_typemap.user_supplied_data_types = r.result
.include "${te_file.arc_path}/t.sys_types.h"
.emit to file "${te_file.system_include_path}/${te_file.types}.${te_file.hdr_file_ext}"
.//
.//=============================================================================
.// Generate sys_user_co.h into include directory.
.//=============================================================================
.include "${te_file.arc_path}/t.sys_user_co.h"
.emit to file "${te_file.system_include_path}/${te_file.callout}.${te_file.hdr_file_ext}"
.//
.//=============================================================================
.// Generate sys_user_co.c into source directory.
.//=============================================================================
.include "${te_file.arc_path}/t.sys_user_co.c"
.emit to file "${te_file.system_include_path}/${te_file.callout}.${te_file.src_file_ext}"
.//
.//=============================================================================
.// Generate TIM_bridge.h into system include.
.//=============================================================================
.if ( not_empty tim_te_ee )
.include "${te_file.arc_path}/t.sys_tim.h"
.emit to file "${te_file.system_include_path}/${te_file.tim}.${te_file.hdr_file_ext}"
.//
.//=============================================================================
.// Generate TIM_bridge.c to system source directory.
.//=============================================================================
.include "${te_file.arc_path}/t.sys_tim.c"
.emit to file "${te_file.system_include_path}/${te_file.tim}.${te_file.src_file_ext}"
.end if
.//
.//=============================================================================
.// Generate sys_xtumlload.h into system gen includes.
.//=============================================================================
.if ( te_sys.InstanceLoading )
.include "${te_file.arc_path}/t.sys_xtumlload.h"
.emit to file "${te_file.system_include_path}/${te_file.xtumlload}.${te_file.hdr_file_ext}"
.end if
.//
.//=============================================================================
.// Generate sys_xtumlload.c into system gen source.
.//=============================================================================
.if ( te_sys.InstanceLoading )
.include "${te_file.arc_path}/t.sys_xtumlload.c"
.emit to file "${te_file.system_source_path}/${te_file.xtumlload}.${te_file.src_file_ext}"
.end if
.print "ending ${info.date}"
.//
