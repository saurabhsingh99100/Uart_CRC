#include <iostream>
#include <cmath>
#include <bitset>
#include <vector>
#include <string>
#include <algorithm>
//#include <bits/stdc++.h>


using namespace std;

/**
 * @brief 
 * 
 * @tparam MASK_LEN 
 * @tparam L 
 */
template <size_t MASK_LEN = 16, size_t L=50>
class CRCGen
{
    private:
    /**
     * @brief Mask used for CRC Checksum Generation
     */
    bitset<MASK_LEN> MASK;

    public:
    /**
     * @brief Construct a new CRCGen object
     * 
     * @param mask bitset<MASK_LEN> object
     */
    CRCGen(bitset<MASK_LEN> mask)
    {
        MASK = mask;
    }
    /**
     * @brief Get the Mask object
     * 
     * @return bitset<MASK_LEN> mask
     */
    bitset<MASK_LEN> getMask()
    {
        return MASK;
    }

    /**
     * @brief Set the Mask object
     * 
     * @param mask mask
     */
    void setMask(bitset<MASK_LEN> mask)
    {
        MASK = mask;
    }

    /**
     * @brief Convert a string(with usual characters) to a binary sting('1' & '0')
     * 
     * @param s string
     * @return string binary string
     */
    static string strToBinary(string s)
    {
        int n = s.length();
        string binaryString;
    
        for (int i = 0; i <= n; i++)
        {
            // convert each char to
            // ASCII value
            int val = int(s[i]);
    
            // Convert ASCII value to binary
            string bin = "";
            while (val > 0)
            {
                (val % 2)? bin.push_back('1') :
                        bin.push_back('0');
                val /= 2;
            }
            std::reverse(bin.begin(), bin.end());
            
            if(bin.length() < 8) // add preceding zeros
            {
                int l = 8-bin.length();
                for(int i=0; i<l; i++)
                    bin = "0"+bin;
            }
    
            binaryString+=bin;
        }
        return binaryString;
    }

    /**
     * @brief Checksum Generator
     * 
     * @param stream binary string
     * @return bitset<MASK_LEN> 
     */
    bitset<MASK_LEN> generateChecksum(const string stream)
    {
        
        bitset<L> bitstream(stream);
        bitset<MASK_LEN> W(0);                // Working area

        bitstream  = bitstream << MASK_LEN-8;   // create MASK_LEN number of zeroes at end (already has a null char at end it 8 zeroes)

        bool overflowbit = false;

        int i=0;
        while(true)
        {
            //getchar();

            // Bitflip operation
            if(overflowbit)
            {
                W = W ^ MASK;
            }
            //cout<<"W = "<<W<<"\n";
            if(i == bitstream.size())
                break;

            // Shift left
            overflowbit = W[MASK_LEN-1];
            W = W << 1;

            // Update LSB
            W[0] = bitstream[bitstream.size()-1];
            bitstream = bitstream << 1;
            //cout<<"> "<<W<<"\n\n";
            i++;
        }

        // Return Checksum
        return W;
    }
};


int main()
{
    // Polynomial = x16 + x12 + x5 + 1
    string mask = "10001000000100001";

    bitset<16> MASK(mask.substr(1));
    CRCGen<16, 40> crc(MASK);

    string s;
    
    cout << "Enter the string:\n";
    cin >> s;
    
    cout << "\nBinary Equivalent: ";
    string b_s = CRCGen<>::strToBinary(s);
    cout << b_s << "\n\n";



    cout << "==== CRC Checksum Generator ====\n";
    
    cout << "Polynomial: <"<<mask<<"> : ";
    
    // Print mask
    for(int i=0; i<mask.length(); i++)
    {
        if(mask[i] == '1')
        {
            if(i==mask.length()-1)
                cout << " + 1";
            else
                cout << ((i!=0)?" + ":"") << "x" << mask.length()-i-1;
        }
    }
    cout<<"\n\n";

    cout << "Checksum: ";
    string checksum = crc.generateChecksum(b_s).to_string();
    unsigned long long checksum_val = crc.generateChecksum(b_s).to_ullong();
    cout <<checksum<<" (0x"<< std::hex << checksum_val <<")\n";

    cout << "\n\n========== CHANNEL =============\n";

    cout << "\nInput Signal : ";
    b_s = b_s.substr(0, b_s.length()-8) + checksum;
    cout << b_s<<"\n";

    int threshold = 10;
    for(int i=0; i<b_s.length(); i++)
    {
        
    }

    cout << "\nOutput Signal: ";
    b_s = b_s.substr(0, b_s.length()-8) + checksum;
    cout << b_s<<"\n";


    




    cout << "\n\n=========== CHECK ==============\n";
    
    

    CRCGen<16> cr(MASK);
    unsigned long long result = cr.generateChecksum(b_s).to_ullong();
    cout<<"Result : "<<result<<" : ";
    if(result == 0)
        cout << "NO ERRORS\n";
    else
        cout << "HAS ERRORS\n";
    
}

// 01001000 01101001 00100001 01100011 11111010