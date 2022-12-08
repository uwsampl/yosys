/*
 *  yosys -- Yosys Open SYnthesis Suite
 *
 *  Copyright (C) 2012  Claire Xenia Wolf <claire@yosyshq.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

#include "kernel/celltypes.h"
#include "kernel/cost.h"
#include "kernel/ff.h"
#include "kernel/ffinit.h"
#include "kernel/log.h"
#include "kernel/register.h"
#include "kernel/sigtools.h"
#include <boost/filesystem.hpp>
#include <cctype>
#include <cerrno>
#include <climits>
#include <filesystem>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <vector>

USING_YOSYS_NAMESPACE PRIVATE_NAMESPACE_BEGIN

  struct LakeroadPass : public Pass {
	LakeroadPass() : Pass("lakeroad", "Invoke Lakeroad for technology mapping.") {}
	void help() override
	{
		//   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
		log("\n");
		log("    lakeroad <top-module-name> <output-signal-name> <architecture> <template>\n");
		log("             \n");
		log("\n");
		log("This pass uses Lakeroad for technology mapping of yosys's internal gate\n");
		log("library to a target architecture.\n");
		log("\n");
	}
	void execute(std::vector<std::string> args, RTLIL::Design *design) override
	{
		log_header(design, "Executing Lakeroad pass (technology mapping using Lakeroad).\n");
		log_push();

		if (args.size() != 5)
			log_cmd_error("Invalid number of arguments!\n");
		auto top_module_name = args[1];
		auto output_signal_name = args[2];
		auto architecture = args[3];
		auto templ8 = args[4];

		auto module_name = top_module_name + "_synthesized_by_lakeroad";

		// Who knew getting a named temporary file was so hard in C++? This isn't a
		// great solution.
		auto verilog_filename = (boost::filesystem::unique_path("%%%%-%%%%-%%%%-%%%%.v").native());
		auto out_verilog_filename = (boost::filesystem::unique_path("%%%%-%%%%-%%%%-%%%%.v").native());
		std::vector<std::string> write_verilog_args;
		write_verilog_args.push_back("write_verilog");
		write_verilog_args.push_back(verilog_filename);
		Pass::call(design, write_verilog_args);

		if (!getenv("LAKEROAD_DIR"))
			log_error("LAKEROAD_DIR environment variable not set. Please set it to the location of the Lakeroad directory.\n");

		std::stringstream ss;
		// clang-format off
		ss << getenv("LAKEROAD_DIR") << "/bin/main.rkt"
		   << " --verilog-module-filepath " << verilog_filename 
			 << " --top-module-name " << top_module_name
			 << " --out-filepath " << out_verilog_filename
		   << " --out-format verilog" 
			 << " --verilog-module-out-signal " << output_signal_name
			 << " --architecture " << architecture
			 << " --template " << templ8
			 << " --module-name " << module_name;
		// clang-format on

		log("Executing Lakeroad:\n%s\n", ss.str().c_str());
		if (system(ss.str().c_str()) != 0)
			log_error("Lakeroad execution failed.\n");

		std::vector<std::string> read_verilog_args;
		read_verilog_args.push_back("read_verilog");
		read_verilog_args.push_back(out_verilog_filename);
		Pass::call(design, read_verilog_args);

		auto new_module = design->module(RTLIL::escape_id(module_name));
		if (new_module == nullptr)
			log_error("Lakeroad returned OK, but no module named %s found.\n", module_name.c_str());

		log("Replacing module %s with the output of Lakeroad", top_module_name.c_str());

		design->remove(design->module(RTLIL::escape_id(top_module_name)));
		design->rename(new_module, RTLIL::escape_id(top_module_name));

		log_pop();
	}
} LakeroadPass;

PRIVATE_NAMESPACE_END
