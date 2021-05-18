#include "verilated.h"
#include <iostream>

template <class VTop> class TESTBENCH 
{
	public:

	VTop * m_core;
	unsigned long tickcount;     		// TickCounter to count clock cycles fom last reset
	unsigned long tickcount_total;     	// TickCounter to count clock cycles

	TESTBENCH(void)                // Constructor: Instantiates a new VTop
    {
		m_core = new VTop;
		tickcount = 0l;
	}

	virtual ~TESTBENCH(void)       // Destructor 
    {
		delete m_core;
		m_core = NULL;
	}

	virtual void reset(void) 
    {
		m_core-> rst_i = 1;

		this -> tick();	// Make sure any inheritance gets applied
		tickcount = 0;
		m_core-> rst_i = 0;
	}

	virtual void tick(void) 
    {
		// Increment our own internal time reference
		tickcount ++;
		tickcount_total++;

        // Make sure any combinatorial logic depending upon
		// inputs that may have changed before we called tick()
		// has settled before the rising edge of the clock.
		m_core -> clk_i = 0;
		m_core -> eval();

		// ---------- Toggle the clock ------------

		// Rising edge
		m_core -> clk_i = 1;
		m_core -> eval();

		// Falling edge
		m_core -> clk_i = 0;
		m_core -> eval();
	}

	virtual bool  done(void)
	{
		return (Verilated::gotFinish()); 
	}
};

// Pointer to backend object
TESTBENCH<VTop> *tb;

void init()
{
	// Instantiate Topmodule
	tb = new TESTBENCH<VCRC_Rx_Engine>();
	tb->reset();
}

void run()
{
    std::cout<<"Enter message to be sent : \n";
    std::string msg <<std::cin;
    std::cout<<"Inject Errors (y/n)\n";
    std::string err_inj <<"Inject Errors (y/n)\n";
    
    int delay = 100;
    
    tb->reset();
        
	
    for(int i=msg.length(); i>=0; i--)
    {
        char letter = 
		
        tb->m_core->CRC_Rx_Engine->rx_i;
        /*
			d.Signals[0] = tb->m_core->Top->luna_soc->CPU->D_Opcode;
			d.Signals[1] = tb->m_core->Top->luna_soc->CPU->D_Func;
			d.Signals[2] = tb->m_core->Top->luna_soc->CPU->D_Rd_Sel;
			d.Signals[3] = tb->m_core->Top->luna_soc->CPU->D_Rs_Sel;
			d.Signals[4] = tb->m_core->Top->luna_soc->CPU->D_Imm;
			d.Signals[5] = tb->m_core->Top->luna_soc->CPU->D_BrReg;
			d.Signals[6] = tb->m_core->Top->luna_soc->CPU->D_BrLink;

			for(int i=0; i<16; i++)
			{
				d.REG[i] = tb->m_core->Top->luna_soc->CPU->rf->regs[i];
			}
			
        */
			
			tb->tick();
    
	}
}
